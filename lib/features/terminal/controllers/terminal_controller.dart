import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:xterm/xterm.dart';
import '../../hosts/models/ssh_host.dart';
import '../models/terminal_session.dart';
import '../services/ssh_service.dart';

class TerminalController {
  final _service = SshService();

  final sessionsNotifier = ValueNotifier<List<TerminalSession>>([]);
  final activeSessionIdNotifier = ValueNotifier<String?>(null);

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

  Future<TerminalSession> createSession({
    required SshHost host,
    String? password,
    String? passphrase,
  }) async {
    final session = TerminalSession(
      id: TerminalSession.generateId(),
      host: host,
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

      // SSH → terminal
      shellSession.stdout.listen(
        (data) => xterm.write(utf8.decode(data, allowMalformed: true)),
      );
      shellSession.stderr.listen(
        (data) => xterm.write(utf8.decode(data, allowMalformed: true)),
      );

      // terminal → SSH
      xterm.onOutput = (data) => shellSession.stdin.add(utf8.encode(data));

      // PTY resize
      xterm.onResize = (width, height, pixelWidth, pixelHeight) {
        shellSession.resizeTerminal(width, height);
      };

      // Handle remote session close
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
      activeSessionIdNotifier.value = remaining.isEmpty ? null : remaining.last.id;
    }
  }

  void setActiveSession(String id) => activeSessionIdNotifier.value = id;

  void _refresh() {
    sessionsNotifier.value = List.from(sessions);
  }

  void dispose() {
    for (final s in sessions) {
      s.client?.close();
    }
    sessionsNotifier.dispose();
    activeSessionIdNotifier.dispose();
  }
}
