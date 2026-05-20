import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';
import '../../hosts/models/ssh_host.dart';

enum SessionStatus { connecting, connected, disconnected, error }

class TerminalSession {
  final String id;
  final SshHost host;
  SessionStatus status;
  SSHClient? client;
  SSHSession? shellSession;
  Terminal? xterm;
  String? errorMessage;

  TerminalSession({
    required this.id,
    required this.host,
    this.status = SessionStatus.connecting,
  });

  bool get isConnected => status == SessionStatus.connected;
  bool get isConnecting => status == SessionStatus.connecting;
  bool get hasError => status == SessionStatus.error;

  static String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}
