import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/command_history_entry.dart';

class CommandHistoryStorage {
  static const _key = 'xell.command_history';
  static const _maxEntries = 100;

  Future<List<CommandHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CommandHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<CommandHistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = entries.length > _maxEntries
        ? entries.sublist(0, _maxEntries)
        : entries;
    await prefs.setString(
      _key,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
