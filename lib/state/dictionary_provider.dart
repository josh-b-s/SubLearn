import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dictionary_match.dart';
import '../services/dictionary/chinese_dictionary.dart';
import '../services/dictionary/dictionary_search.dart';
import 'custom_dictionary_provider.dart';

/// Parses the bundled dictionary once, off the UI thread.
final bundledDictionaryProvider = FutureProvider<ChineseDictionary>((ref) async {
  final text = await rootBundle.loadString('assets/zh-en.tsv');
  return compute(ChineseDictionary.parse, text);
});

/// Bundled dictionary plus the user's custom words.
final dictionaryProvider = FutureProvider<ChineseDictionary>((ref) async {
  final bundled = await ref.watch(bundledDictionaryProvider.future);
  return bundled.withCustom(ref.watch(customDictionaryProvider));
});

/// Debounced search. A new query disposes the old provider, which cancels its pending wait.
final dictionarySearchProvider =
    FutureProvider.autoDispose.family<List<DictionaryMatch>, String>((ref, query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return const [];

  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  await Future<void>.delayed(const Duration(milliseconds: 250));
  if (cancelled) return const [];

  final dictionary = await ref.watch(dictionaryProvider.future);
  return dictionary.search(trimmed);
});
