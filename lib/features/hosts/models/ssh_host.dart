import 'os_type.dart';

enum AuthType { password, privateKey, sshAgent }

class SshHost {
  final String id;
  final String name;
  final String hostname;
  final int port;
  final String username;
  final AuthType authType;
  final String? privateKeyPath;
  final List<String> tags;
  final bool isFavorite;
  final DateTime? lastConnectedAt;
  final String? notes;
  final OsType? detectedOs;

  const SshHost({
    required this.id,
    required this.name,
    required this.hostname,
    required this.port,
    required this.username,
    required this.authType,
    this.privateKeyPath,
    this.tags = const [],
    this.isFavorite = false,
    this.lastConnectedAt,
    this.notes,
    this.detectedOs,
  });

  SshHost copyWith({
    String? name,
    String? hostname,
    int? port,
    String? username,
    AuthType? authType,
    String? privateKeyPath,
    List<String>? tags,
    bool? isFavorite,
    DateTime? lastConnectedAt,
    String? notes,
    OsType? detectedOs,
  }) => SshHost(
    id: id,
    name: name ?? this.name,
    hostname: hostname ?? this.hostname,
    port: port ?? this.port,
    username: username ?? this.username,
    authType: authType ?? this.authType,
    privateKeyPath: privateKeyPath ?? this.privateKeyPath,
    tags: tags ?? this.tags,
    isFavorite: isFavorite ?? this.isFavorite,
    lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
    notes: notes ?? this.notes,
    detectedOs: detectedOs ?? this.detectedOs,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hostname': hostname,
    'port': port,
    'username': username,
    'authType': authType.name,
    'privateKeyPath': privateKeyPath,
    'tags': tags,
    'isFavorite': isFavorite,
    'lastConnectedAt': lastConnectedAt?.toIso8601String(),
    'notes': notes,
    'detectedOs': detectedOs?.name,
  };

  factory SshHost.fromJson(Map<String, dynamic> json) => SshHost(
    id: json['id'] as String,
    name: json['name'] as String,
    hostname: json['hostname'] as String,
    port: json['port'] as int,
    username: json['username'] as String,
    authType: AuthType.values.byName(json['authType'] as String),
    privateKeyPath: json['privateKeyPath'] as String?,
    tags: (json['tags'] as List<dynamic>).cast<String>(),
    isFavorite: json['isFavorite'] as bool,
    lastConnectedAt: json['lastConnectedAt'] != null
        ? DateTime.parse(json['lastConnectedAt'] as String)
        : null,
    notes: json['notes'] as String?,
    detectedOs: json['detectedOs'] != null
        ? OsType.values.byName(json['detectedOs'] as String)
        : null,
  );

  static String generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${Object().hashCode.abs()}';

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        hostname.toLowerCase().contains(q) ||
        username.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }
}
