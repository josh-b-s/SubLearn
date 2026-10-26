import '../services/dictionary/pinyin_key.dart';
import '../services/vocabulary/saved_word_mastery.dart';
import 'review_log.dart';
import 'saved_word.dart';

enum VocabularySort {
  newest('Newest first'),
  oldest('Oldest first'),
  dueSoonest('Due soonest'),
  recentlyReviewed('Recently reviewed'),
  mostMissed('Most missed'),
  pinyin('Pinyin A to Z');

  const VocabularySort(this.label);
  final String label;

  /// `logs` is only read by the review-based sorts.
  List<SavedWord> sorted(List<SavedWord> words, List<ReviewLog> logs) {
    final list = [...words];
    switch (this) {
      case newest:
        list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case oldest:
        list.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
      case dueSoonest:
        // Mastered words aren't quizzed, so their stale due dates would otherwise lead the list.
        list.sort((a, b) {
          if (a.isMastered != b.isMastered) return a.isMastered ? 1 : -1;
          return a.dueDate.compareTo(b.dueDate);
        });
      case recentlyReviewed:
        final last = <String, DateTime>{};
        for (final log in logs) {
          final seen = last[log.word];
          if (seen == null || log.date.isAfter(seen)) last[log.word] = log.date;
        }
        final never = DateTime.fromMillisecondsSinceEpoch(0);
        list.sort((a, b) {
          final x = last[a.word] ?? never;
          final y = last[b.word] ?? never;
          return x != y ? y.compareTo(x) : b.dateAdded.compareTo(a.dateAdded);
        });
      case mostMissed:
        final misses = <String, int>{};
        for (final log in logs.where((l) => !l.correct)) {
          misses[log.word] = (misses[log.word] ?? 0) + 1;
        }
        list.sort((a, b) {
          final x = misses[a.word] ?? 0;
          final y = misses[b.word] ?? 0;
          return x != y ? y.compareTo(x) : b.dateAdded.compareTo(a.dateAdded);
        });
      case pinyin:
        list.sort((a, b) => foldDiacritics(a.pinyin).compareTo(foldDiacritics(b.pinyin)));
    }
    return list;
  }
}
