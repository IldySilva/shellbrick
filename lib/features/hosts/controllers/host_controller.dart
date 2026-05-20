import 'package:flutter/foundation.dart';
import '../data/credential_storage.dart';
import '../data/host_local_storage.dart';
import '../models/ssh_host.dart';

class HostController {
  final _storage = HostLocalStorage();
  final _credentials = CredentialStorage();
  final hostsNotifier = ValueNotifier<List<SshHost>>([]);

  Future<void> load() async {
    hostsNotifier.value = await _storage.loadHosts();
  }

  Future<void> add(SshHost host) async {
    hostsNotifier.value = [...hostsNotifier.value, host];
    await _storage.saveHosts(hostsNotifier.value);
  }

  Future<void> update(SshHost host) async {
    hostsNotifier.value = hostsNotifier.value
        .map((h) => h.id == host.id ? host : h)
        .toList();
    await _storage.saveHosts(hostsNotifier.value);
  }

  Future<void> delete(String id) async {
    hostsNotifier.value =
        hostsNotifier.value.where((h) => h.id != id).toList();
    await _storage.saveHosts(hostsNotifier.value);
    await _credentials.deleteCredentials(id);
  }

  Future<void> toggleFavorite(String id) async {
    final host = hostsNotifier.value.firstWhere((h) => h.id == id);
    await update(host.copyWith(isFavorite: !host.isFavorite));
  }

  Future<void> markConnected(String id) async {
    final host = hostsNotifier.value.firstWhere((h) => h.id == id);
    await update(host.copyWith(lastConnectedAt: DateTime.now()));
  }

  void dispose() => hostsNotifier.dispose();
}
