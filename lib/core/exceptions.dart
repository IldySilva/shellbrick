class SshException implements Exception {
  final String message;
  const SshException(this.message);

  @override
  String toString() => message;
}
