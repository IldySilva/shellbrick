import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import '../models/sftp_entry.dart';
import '../services/sftp_service.dart';

class SftpController {
  final _service = SftpService();

  SftpClient? _sftp;

  final entriesNotifier = ValueNotifier<List<SftpEntry>>([]);
  final currentPathNotifier = ValueNotifier<String>('/');
  final loadingNotifier = ValueNotifier<bool>(false);
  final errorNotifier = ValueNotifier<String?>(null);

  String get currentPath => currentPathNotifier.value;

  Future<void> connect(SSHClient client) async {
    _sftp?.close();
    _sftp = null;
    entriesNotifier.value = [];
    currentPathNotifier.value = '/';
    errorNotifier.value = null;

    try {
      _sftp = await _service.open(client);
      await _loadDir('/');
    } catch (e) {
      errorNotifier.value = 'Could not open SFTP session: ${e.toString()}';
    }
  }

  Future<void> navigate(String path) => _loadDir(path);

  Future<void> navigateUp() {
    final parts = currentPath.split('/')..removeWhere((p) => p.isEmpty);
    if (parts.isEmpty) return Future.value();
    parts.removeLast();
    final parent = parts.isEmpty ? '/' : '/${parts.join('/')}';
    return _loadDir(parent);
  }

  Future<void> refresh() => _loadDir(currentPath);

  Future<void> upload(String remoteName, Uint8List data) async {
    final sftp = _sftp;
    if (sftp == null) return;
    final remotePath = currentPath == '/'
        ? '/$remoteName'
        : '$currentPath/$remoteName';
    loadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      await _service.upload(sftp, remotePath, data);
      await _loadDir(currentPath);
    } catch (e) {
      errorNotifier.value = 'Upload failed: ${e.toString()}';
      loadingNotifier.value = false;
    }
  }

  Future<Uint8List?> download(SftpEntry entry) async {
    final sftp = _sftp;
    if (sftp == null) return null;
    loadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      final data = await _service.download(sftp, entry.path);
      return data;
    } catch (e) {
      errorNotifier.value = 'Download failed: ${e.toString()}';
      return null;
    } finally {
      loadingNotifier.value = false;
    }
  }

  Future<void> rename(SftpEntry entry, String newName) async {
    final sftp = _sftp;
    if (sftp == null) return;
    final dir = currentPath == '/' ? '' : currentPath;
    final newPath = '$dir/$newName';
    loadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      await _service.rename(sftp, entry.path, newPath);
      await _loadDir(currentPath);
    } catch (e) {
      errorNotifier.value = 'Rename failed: ${e.toString()}';
      loadingNotifier.value = false;
    }
  }

  Future<void> delete(SftpEntry entry) async {
    final sftp = _sftp;
    if (sftp == null) return;
    loadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      await _service.delete(sftp, entry.path, isDirectory: entry.isDirectory);
      await _loadDir(currentPath);
    } catch (e) {
      errorNotifier.value = 'Delete failed: ${e.toString()}';
      loadingNotifier.value = false;
    }
  }

  Future<void> _loadDir(String path) async {
    final sftp = _sftp;
    if (sftp == null) return;
    loadingNotifier.value = true;
    errorNotifier.value = null;
    try {
      final entries = await _service.listDir(sftp, path);
      currentPathNotifier.value = path;
      entriesNotifier.value = entries;
    } catch (e) {
      errorNotifier.value = 'Could not read directory: ${e.toString()}';
    } finally {
      loadingNotifier.value = false;
    }
  }

  void dispose() {
    _sftp?.close();
    entriesNotifier.dispose();
    currentPathNotifier.dispose();
    loadingNotifier.dispose();
    errorNotifier.dispose();
  }
}
