import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import '../../../core/exceptions.dart';
import '../models/tunnel_entry.dart';
import '../services/tunnel_service.dart';

class TunnelController {
  final _service = TunnelService();

  final tunnelsNotifier = ValueNotifier<List<TunnelEntry>>([]);

  // Server sockets kept for teardown, keyed by tunnel id.
  final _sockets = <String, ServerSocket>{};

  List<TunnelEntry> get tunnels => tunnelsNotifier.value;

  Future<void> create({
    required SSHClient client,
    required String sessionId,
    required int localPort,
    required String remoteHost,
    required int remotePort,
    String? label,
  }) async {
    // Reject duplicates on the same local port.
    if (tunnels.any((t) => t.localPort == localPort)) {
      throw SshException('A tunnel on port $localPort already exists.');
    }

    final serverSocket = await _service.forward(
      client: client,
      localPort: localPort,
      remoteHost: remoteHost,
      remotePort: remotePort,
    );

    final entry = TunnelEntry(
      id: TunnelEntry.generateId(),
      sessionId: sessionId,
      localPort: localPort,
      remoteHost: remoteHost,
      remotePort: remotePort,
      label: label?.trim().isEmpty == true ? null : label?.trim(),
    );

    _sockets[entry.id] = serverSocket;
    tunnelsNotifier.value = [...tunnels, entry];
  }

  Future<void> close(String id) async {
    await _sockets[id]?.close();
    _sockets.remove(id);
    tunnelsNotifier.value = tunnels.where((t) => t.id != id).toList();
  }

  Future<void> closeForSession(String sessionId) async {
    final ids = tunnels
        .where((t) => t.sessionId == sessionId)
        .map((t) => t.id)
        .toList();
    for (final id in ids) {
      await _sockets[id]?.close();
      _sockets.remove(id);
    }
    tunnelsNotifier.value =
        tunnels.where((t) => t.sessionId != sessionId).toList();
  }

  void dispose() {
    for (final s in _sockets.values) {
      s.close();
    }
    _sockets.clear();
    tunnelsNotifier.dispose();
  }
}
