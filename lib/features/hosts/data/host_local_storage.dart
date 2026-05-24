import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ssh_host.dart';

class HostLocalStorage {
  static const _key = 'xell.hosts';

  Future<List<SshHost>> loadHosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SshHost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHosts(List<SshHost> hosts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(hosts.map((h) => h.toJson()).toList()),
    );
  }
}
