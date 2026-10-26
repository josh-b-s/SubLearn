import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dictionary_entry.dart';
import '../services/vocabulary/custom_meanings.dart';
import 'core_providers.dart';

/// The user's own dictionary words.
class CustomDictionaryNotifier extends Notifier<Map<String, DictionaryEntry>> {
  static const _key = 'customDictionaryEntries';

  @override
  Map<String, DictionaryEntry> build() => {
        for (final e in ref.read(jsonStoreProvider).readMap(_key).entries)
          e.key: DictionaryEntry.fromJson(e.value as Map<String, dynamic>),
      };

  /// Adds or overwrites a word. [pinyin] is used as given, so callers fill in a blank one first.
  void add({required String word, required String pinyin, required String meaning}) {
    final meanings = parseMeanings(meaning);
    if (word.isEmpty || meanings.isEmpty) return;

    final next = {...state, word: DictionaryEntry(pinyin: pinyin.replaceAll(' ', '').trim(), meanings: meanings)};
    state = next;
    unawaited(ref.read(jsonStoreProvider).writeMap(_key, {
      for (final e in next.entries) e.key: e.value.toJson(),
    }));
  }
}

final customDictionaryProvider =
    NotifierProvider<CustomDictionaryNotifier, Map<String, DictionaryEntry>>(CustomDictionaryNotifier.new);
