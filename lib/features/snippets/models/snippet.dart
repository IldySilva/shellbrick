import 'dart:math';

class Snippet {
  final String id;
  final String title;
  final String command;
  final String? description;
  final List<String> tags;

  const Snippet({
    required this.id,
    required this.title,
    required this.command,
    this.description,
    this.tags = const [],
  });

  factory Snippet.fromJson(Map<String, dynamic> json) => Snippet(
        id: json['id'] as String,
        title: json['title'] as String,
        command: json['command'] as String,
        description: json['description'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'command': command,
        if (description != null) 'description': description,
        'tags': tags,
      };

  Snippet copyWith({
    String? title,
    String? command,
    String? description,
    List<String>? tags,
  }) =>
      Snippet(
        id: id,
        title: title ?? this.title,
        command: command ?? this.command,
        description: description ?? this.description,
        tags: tags ?? this.tags,
      );

  static String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random();
    return 'snip_${List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join()}';
  }
}
