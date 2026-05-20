import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import '../models/sftp_entry.dart';

class SftpService {
  Future<SftpClient> open(SSHClient client) => client.sftp();

  Future<List<SftpEntry>> listDir(SftpClient sftp, String path) async {
    final names = await sftp.listdir(path);
    final entries = <SftpEntry>[];

    for (final name in names) {
      if (name.filename == '.' || name.filename == '..') continue;
      final entryPath = path == '/' ? '/${name.filename}' : '$path/${name.filename}';
      final isDir = name.attr.isDirectory;
      final modTime = name.attr.modifyTime;

      entries.add(SftpEntry(
        name: name.filename,
        path: entryPath,
        isDirectory: isDir,
        size: isDir ? null : name.attr.size?.toInt(),
        modifiedAt: modTime != null
            ? DateTime.fromMillisecondsSinceEpoch(modTime * 1000)
            : null,
      ));
    }

    // Directories first, then alphabetical within each group.
    entries.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return entries;
  }

  Future<Uint8List> download(SftpClient sftp, String remotePath) async {
    final file = await sftp.open(remotePath);
    try {
      final chunks = <Uint8List>[];
      await for (final chunk in file.read()) {
        chunks.add(chunk);
      }
      final total = chunks.fold(0, (sum, c) => sum + c.length);
      final result = Uint8List(total);
      var offset = 0;
      for (final chunk in chunks) {
        result.setAll(offset, chunk);
        offset += chunk.length;
      }
      return result;
    } finally {
      await file.close();
    }
  }

  Future<void> upload(
    SftpClient sftp,
    String remotePath,
    Uint8List data,
  ) async {
    final file = await sftp.open(
      remotePath,
      mode: SftpFileOpenMode.write |
          SftpFileOpenMode.create |
          SftpFileOpenMode.truncate,
    );
    try {
      await file.writeBytes(data);
    } finally {
      await file.close();
    }
  }

  Future<void> rename(
    SftpClient sftp,
    String oldPath,
    String newPath,
  ) => sftp.rename(oldPath, newPath);

  Future<void> delete(
    SftpClient sftp,
    String path, {
    required bool isDirectory,
  }) => isDirectory ? sftp.rmdir(path) : sftp.remove(path);
}
