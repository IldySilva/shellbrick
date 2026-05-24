const String kDefaultWorkspaceId = 'general';

class Workspace {
  final String id;
  String name;

  Workspace({required this.id, required this.name});

  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  static Workspace get defaultWorkspace =>
      Workspace(id: kDefaultWorkspaceId, name: 'General');
}
