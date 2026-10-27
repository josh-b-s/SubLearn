import '../../models/saved_word.dart';
import '../../models/session/session_entry.dart';
import '../../models/session/session_summary.dart';
import '../vocabulary/saved_word_mastery.dart';

/// Turns a session's word counts into the numbers and lists on the summary screen.
abstract final class SessionSummaryBuilder {
  static const maxTopWords = 8;

  /// Known = saved and mastered, learning = saved but not mastered, new = not saved.
  static SessionSummary? build(List<SessionEntry> entries, List<SavedWord> saved) {
    if (entries.isEmpty) return null;
    final byWord = {for (final w in saved.reversed) w.word: w};

    var known = 0, learning = 0, fresh = 0;
    for (final entry in entries) {
      final word = byWord[entry.token.text];
      if (word == null) {
        fresh++;
      } else if (word.isMastered) {
        known++;
      } else {
        learning++;
      }
    }

    final top = entries.where((e) => byWord[e.token.text]?.isMastered != true).toList()
      ..sort((a, b) => a.count != b.count ? b.count.compareTo(a.count) : a.token.text.compareTo(b.token.text));
    final shown = top.take(maxTopWords).toList();

    return SessionSummary(
      alreadyKnown: known,
      learning: learning,
      newWords: fresh,
      topWords: shown,
      unsavedTopWords: {for (final e in shown) if (!byWord.containsKey(e.token.text)) e.token.text},
    );
  }
}
