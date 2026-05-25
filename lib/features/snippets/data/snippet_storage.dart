import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/snippet.dart';

class SnippetStorage {
  static const _key = 'xell.snippets';

  Future<List<Snippet>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Snippet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<Snippet> snippets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(snippets.map((s) => s.toJson()).toList()));
  }
}
