import 'package:flutter/foundation.dart';
import '../data/command_history_storage.dart';
import '../models/command_history_entry.dart';

class CommandHistoryController {
  final _storage = CommandHistoryStorage();
  final entriesNotifier = ValueNotifier<List<CommandHistoryEntry>>([]);

  List<CommandHistoryEntry> get entries => entriesNotifier.value;

  Future<void> load() async {
    entriesNotifier.value = await _storage.load();
  }

  Future<void> add(String command) async {
    final trimmed = command.trim().replaceAll(RegExp(r'\n$'), '');
    if (trimmed.isEmpty) return;
    final entry = CommandHistoryEntry(
      id: CommandHistoryEntry.generateId(),
      command: trimmed,
      ranAt: DateTime.now(),
    );
    // Newest at front, deduplicate consecutive identical commands.
    final current = entries.where((e) => e.command != trimmed).toList();
    entriesNotifier.value = [entry, ...current];
    await _storage.save(entriesNotifier.value);
  }

  Future<void> clear() async {
    entriesNotifier.value = [];
    await _storage.clear();
  }

  void dispose() => entriesNotifier.dispose();
}
