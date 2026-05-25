class CommandHistoryEntry {
  final String id;
  final String command;
  final DateTime ranAt;

  const CommandHistoryEntry({
    required this.id,
    required this.command,
    required this.ranAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'command': command,
        'ranAt': ranAt.toIso8601String(),
      };

  factory CommandHistoryEntry.fromJson(Map<String, dynamic> json) =>
      CommandHistoryEntry(
        id: json['id'] as String,
        command: json['command'] as String,
        ranAt: DateTime.parse(json['ranAt'] as String),
      );

  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}
