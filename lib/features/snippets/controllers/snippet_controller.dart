import 'package:flutter/foundation.dart';
import '../data/snippet_storage.dart';
import '../models/snippet.dart';

class SnippetController {
  final _storage = SnippetStorage();
  final snippetsNotifier = ValueNotifier<List<Snippet>>([]);

  List<Snippet> get snippets => snippetsNotifier.value;

  Future<void> load() async {
    snippetsNotifier.value = await _storage.load();
  }

  Future<void> add(Snippet snippet) async {
    snippetsNotifier.value = [...snippets, snippet];
    await _storage.save(snippets);
  }

  Future<void> update(Snippet snippet) async {
    snippetsNotifier.value = [
      for (final s in snippets) s.id == snippet.id ? snippet : s,
    ];
    await _storage.save(snippets);
  }

  Future<void> delete(String id) async {
    snippetsNotifier.value = snippets.where((s) => s.id != id).toList();
    await _storage.save(snippets);
  }

  void dispose() => snippetsNotifier.dispose();
}
