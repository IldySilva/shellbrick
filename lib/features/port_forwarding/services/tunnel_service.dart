import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import '../../../core/exceptions.dart';

class TunnelService {
  Future<ServerSocket> forward({
    required SSHClient client,
    required int localPort,
    required String remoteHost,
    required int remotePort,
  }) async {
    final ServerSocket serverSocket;
    try {
      serverSocket = await ServerSocket.bind('127.0.0.1', localPort);
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 48 || e.osError?.errorCode == 98) {
        // 48 = EADDRINUSE on macOS, 98 = EADDRINUSE on Linux
        throw SshException('Port $localPort is already in use.');
      }
      throw SshException('Could not bind local port $localPort: ${e.message}');
    }

    serverSocket.listen(
      (socket) async {
        try {
          final forward = await client.forwardLocal(remoteHost, remotePort);
          forward.stream.cast<List<int>>().pipe(socket);
          socket.cast<List<int>>().pipe(forward.sink);
        } catch (_) {
          await socket.close();
        }
      },
      onError: (_) {},
    );

    return serverSocket;
  }
}
