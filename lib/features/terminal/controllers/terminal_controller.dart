import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';
import '../../hosts/models/ssh_host.dart';
import '../models/terminal_session.dart';
import '../models/workspace.dart';
import '../services/ssh_service.dart';

class TerminalController {
  final _service = SshService();

  final sessionsNotifier = ValueNotifier<List<TerminalSession>>([]);
  final activeSessionIdNotifier = ValueNotifier<String?>(null);

  // Split pane
  final splitAxisNotifier = ValueNotifier<Axis?>(null);
  final splitSessionIdNotifier = ValueNotifier<String?>(null);
  final activePaneNotifier = ValueNotifier<int>(0); // 0 = primary, 1 = secondary

  // Workspaces
  final workspacesNotifier = ValueNotifier<List<Workspace>>(
    [Workspace.defaultWorkspace],
  );
  final activeWorkspaceIdNotifier = ValueNotifier<String>(kDefaultWorkspaceId);

  List<TerminalSession> get sessions => sessionsNotifier.value;

  TerminalSession? get activeSession {
    final id = activeSessionIdNotifier.value;
    if (id == null) return null;
    try {
      return sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  TerminalSession? get splitSession {
    final id = splitSessionIdNotifier.value;
    if (id == null) return null;
    try {
      return sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<TerminalSession> get activeWorkspaceSessions {
    final wsId = activeWorkspaceIdNotifier.value;
    return sessions.where((s) => s.workspaceId == wsId).toList();
  }

  // ── Session creation ──────────────────────────────────────────────────────

  Future<TerminalSession> createSession({
    required SshHost host,
    String? password,
    String? passphrase,
  }) async {
    final session = TerminalSession(
      id: TerminalSession.generateId(),
      host: host,
      workspaceId: activeWorkspaceIdNotifier.value,
    );

    sessionsNotifier.value = [...sessions, session];
    activeSessionIdNotifier.value = session.id;

    try {
      final client = await _service.connect(
        host: host,
        password: password,
        passphrase: passphrase,
      );
      final shellSession = await _service.openShell(client);

      final xterm = Terminal(maxLines: 10000);

      shellSession.stdout.listen(
        (data) => xterm.write(utf8.decode(data, allowMalformed: true)),
      );
      shellSession.stderr.listen(
        (data) => xterm.write(utf8.decode(data, allowMalformed: true)),
      );

      xterm.onOutput = (data) => shellSession.stdin.add(utf8.encode(data));

      xterm.onResize = (width, height, pixelWidth, pixelHeight) {
        shellSession.resizeTerminal(width, height);
      };

      shellSession.done.then((_) {
        session.status = SessionStatus.disconnected;
        _refresh();
      }).catchError((_) {});

      session.client = client;
      session.shellSession = shellSession;
      session.xterm = xterm;
      session.status = SessionStatus.connected;
      _refresh();
      return session;
    } catch (e) {
      session.status = SessionStatus.error;
      session.errorMessage = e.toString();
      _refresh();
      rethrow;
    }
  }

  Future<void> closeSession(String id) async {
    final index = sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final session = sessions[index];
    session.client?.close();
    session.status = SessionStatus.disconnected;

    final remaining = sessions.where((s) => s.id != id).toList();
    sessionsNotifier.value = remaining;

    if (activeSessionIdNotifier.value == id) {
      final wsId = activeWorkspaceIdNotifier.value;
      final wsRemaining = remaining.where((s) => s.workspaceId == wsId).toList();
      activeSessionIdNotifier.value =
          wsRemaining.isEmpty ? null : wsRemaining.last.id;
    }

    if (splitSessionIdNotifier.value == id) {
      splitSessionIdNotifier.value = null;
      if (sessions.isEmpty) splitAxisNotifier.value = null;
    }
  }

  void setActiveSession(String id) {
    if (activePaneNotifier.value == 1) {
      splitSessionIdNotifier.value = id;
    } else {
      activeSessionIdNotifier.value = id;
    }
  }

  // ── Split pane ────────────────────────────────────────────────────────────

  void splitHorizontal() => _split(Axis.horizontal);
  void splitVertical() => _split(Axis.vertical);

  void _split(Axis axis) {
    final id = activeSessionIdNotifier.value;
    if (id == null) return;
    splitAxisNotifier.value = axis;
    splitSessionIdNotifier.value = id;
  }

  void closeSplit() {
    splitAxisNotifier.value = null;
    splitSessionIdNotifier.value = null;
    activePaneNotifier.value = 0;
  }

  void focusPane(int pane) => activePaneNotifier.value = pane;

  // ── Workspaces ────────────────────────────────────────────────────────────

  void createWorkspace(String name) {
    final ws = Workspace(id: Workspace.generateId(), name: name);
    workspacesNotifier.value = [...workspacesNotifier.value, ws];
    activeWorkspaceIdNotifier.value = ws.id;
    // Close split when switching workspace
    closeSplit();
  }

  void switchWorkspace(String id) {
    if (activeWorkspaceIdNotifier.value == id) return;
    activeWorkspaceIdNotifier.value = id;
    closeSplit();
    final wsSessions = sessions.where((s) => s.workspaceId == id).toList();
    activeSessionIdNotifier.value =
        wsSessions.isEmpty ? null : wsSessions.last.id;
  }

  void renameWorkspace(String id, String name) {
    final ws = workspacesNotifier.value.firstWhereOrNull((w) => w.id == id);
    if (ws == null) return;
    ws.name = name;
    workspacesNotifier.value = List.from(workspacesNotifier.value);
  }

  void deleteWorkspace(String id) {
    if (id == kDefaultWorkspaceId) return;
    final updated = workspacesNotifier.value.where((w) => w.id != id).toList();
    workspacesNotifier.value = updated;
    if (activeWorkspaceIdNotifier.value == id) {
      switchWorkspace(kDefaultWorkspaceId);
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _refresh() {
    sessionsNotifier.value = List.from(sessions);
  }

  void dispose() {
    for (final s in sessions) {
      s.client?.close();
    }
    sessionsNotifier.dispose();
    activeSessionIdNotifier.dispose();
    splitAxisNotifier.dispose();
    splitSessionIdNotifier.dispose();
    activePaneNotifier.dispose();
    workspacesNotifier.dispose();
    activeWorkspaceIdNotifier.dispose();
  }
}

extension _ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
