class SftpEntry {
  final String name;
  final String path;
  final bool isDirectory;
  final int? size;
  final DateTime? modifiedAt;

  const SftpEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size,
    this.modifiedAt,
  });

  String get displaySize {
    if (isDirectory) return '';
    final s = size ?? 0;
    if (s < 1024) return '${s}B';
    if (s < 1024 * 1024) return '${(s / 1024).toStringAsFixed(1)}KB';
    if (s < 1024 * 1024 * 1024) {
      return '${(s / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(s / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
