import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dictionary_match.dart';
import '../models/saved_word.dart';
import '../models/word_token.dart';
import '../services/vocabulary/saved_word_mastery.dart';
import '../services/vocabulary/saved_word_review.dart';
import 'clock_provider.dart';
import 'core_providers.dart';
import 'review_logs_provider.dart';

class WordsNotifier extends Notifier<List<SavedWord>> {
  static const _key = 'savedWords';

  @override
  List<SavedWord> build() => ref.read(jsonStoreProvider).readList(_key, SavedWord.fromJson);

  DateTime get _now => ref.read(clockProvider)();

  SavedWord? find(String word) {
    for (final w in state) {
      if (w.word == word) return w;
    }
    return null;
  }

  /// Saves the word, or removes it when it is already saved.
  void toggleSaved(WordToken token) {
    if (find(token.text) != null) {
      remove({token.text});
    } else {
      _save([
        ...state,
        SavedWord.fresh(word: token.text, pinyin: token.pinyin, meanings: token.meanings, now: _now),
      ]);
    }
  }

  void remove(Set<String> words) {
    _save(state.where((w) => !words.contains(w.word)).toList());
    ref.read(reviewLogsProvider.notifier).removeWords(words);
  }

  /// Manual override from the mastery slider.
  void setProgress(String word, double score) =>
      _replace(word, (w) => w.withProgress(score, _now));

  /// Adds a dictionary word at a chosen mastery score, or updates it if already saved.
  /// Levels 2 and 3 also get a review so the word isn't quizzed immediately.
  void addKnown(DictionaryMatch match, double progress) {
    final existing = find(match.word) ??
        SavedWord.fresh(word: match.word, pinyin: match.entry.pinyin, meanings: match.entry.meanings, now: _now);
    var word = existing.withProgress(progress, _now);
    word = switch (word.level) {
      2 => word.reviewed(3, _now),
      3 => word.reviewed(4, _now),
      _ => word,
    };
    final exists = state.any((w) => w.word == match.word);
    _save(exists ? [for (final w in state) w.word == match.word ? word : w] : [...state, word]);
  }

  /// Records one graded first attempt and returns the word before and after.
  ({SavedWord before, SavedWord after})? recordAnswer(String word, {required bool correct, required int questionLevel}) {
    final before = find(word);
    if (before == null) return null;
    final after = before.recorded(correct: correct, questionLevel: questionLevel, now: _now);
    _replace(word, (_) => after);
    return (before: before, after: after);
  }

  void _replace(String word, SavedWord Function(SavedWord) change) =>
      _save([for (final w in state) w.word == word ? change(w) : w]);

  void _save(List<SavedWord> words) {
    state = words;
    unawaited(ref.read(jsonStoreProvider).writeList(_key, words, (w) => w.toJson()));
  }
}

final wordsProvider = NotifierProvider<WordsNotifier, List<SavedWord>>(WordsNotifier.new);

final savedWordSetProvider = Provider<Set<String>>(
  (ref) => {for (final w in ref.watch(wordsProvider)) w.word},
);

final levelsByWordProvider = Provider<Map<String, int>>(
  (ref) => {for (final w in ref.watch(wordsProvider)) w.word: w.level},
);
