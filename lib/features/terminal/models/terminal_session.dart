import 'dart:async';
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';
import '../../hosts/models/ssh_host.dart';
import 'workspace.dart';

enum SessionStatus { connecting, connected, disconnected, error }

class TerminalSession {
  final String id;
  final SshHost host;
  SessionStatus status;
  SSHClient? client;
  SSHSession? shellSession;
  Terminal? xterm;
  String? errorMessage;
  String workspaceId;

  // Managed by TerminalController — cancelled on close.
  StreamSubscription<List<int>>? stdoutSub;
  StreamSubscription<List<int>>? stderrSub;
  Timer? outputFlushTimer;

  TerminalSession({
    required this.id,
    required this.host,
    this.status = SessionStatus.connecting,
    this.workspaceId = kDefaultWorkspaceId,
  });

  bool get isConnected => status == SessionStatus.connected;
  bool get isConnecting => status == SessionStatus.connecting;
  bool get hasError => status == SessionStatus.error;

  static String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}
