import 'dart:io';

import '../models/ssh_host.dart';

class SshConfigEntry {
  final String alias;
  final String hostname;
  final String username;
  final int port;
  final String? identityFile;

  const SshConfigEntry({
    required this.alias,
    required this.hostname,
    required this.username,
    required this.port,
    this.identityFile,
  });

  SshHost toSshHost() => SshHost(
    id: SshHost.generateId(),
    name: alias,
    hostname: hostname,
    port: port,
    username: username,
    authType: identityFile != null ? AuthType.privateKey : AuthType.password,
    privateKeyPath: identityFile,
  );
}

class SshConfigImporter {
  static String get _configPath {
    final home = Platform.environment['HOME'] ?? '';
    return '$home/.ssh/config';
  }

  static Future<List<SshConfigEntry>> parse() async {
    final file = File(_configPath);
    if (!await file.exists()) return [];
    final lines = await file.readAsLines();
    return _parseLines(lines);
  }

  static List<SshConfigEntry> _parseLines(List<String> lines) {
    final entries = <SshConfigEntry>[];
    final defaultUser = Platform.environment['USER'] ?? 'root';

    String? alias;
    String? hostname;
    String? username;
    int port = 22;
    String? identityFile;

    void flush() {
      final a = alias;
      final h = hostname;
      if (a != null && h != null) {
        entries.add(SshConfigEntry(
          alias: a,
          hostname: h,
          username: username ?? defaultUser,
          port: port,
          identityFile: identityFile,
        ));
      }
      hostname = null;
      username = null;
      port = 22;
      identityFile = null;
    }

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final space = line.indexOf(RegExp(r'\s'));
      if (space == -1) continue;

      final key = line.substring(0, space).toLowerCase();
      final value = line.substring(space + 1).trim();

      switch (key) {
        case 'host':
          if (!value.contains('*')) {
            flush();
            alias = value;
          }
        case 'hostname':
          hostname = value;
        case 'user':
          username = value;
        case 'port':
          port = int.tryParse(value) ?? 22;
        case 'identityfile':
          final home = Platform.environment['HOME'] ?? '';
          identityFile = value.replaceFirst('~', home);
      }
    }
    flush();

    return entries;
  }
}
