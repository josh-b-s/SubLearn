import '../../models/saved_word.dart';
import '../learning/mastery.dart';
import 'saved_word_review.dart';

extension SavedWordMastery on SavedWord {
  bool get isMastered => Mastery.isMastered(level);

  /// Level plus progress through it, such as "2.5".
  String get masteryLabel => Mastery.label(level, levelStreak);
  double get masteryScore => Mastery.score(level, levelStreak);

  /// Records one graded answer: SM-2 schedule plus mastery level.
  /// A question easier than the word's level (a fallback) only affects the schedule.
  SavedWord recorded({required bool correct, required int questionLevel, required DateTime now}) {
    final scheduled = reviewed(Mastery.quality(questionLevel, correct: correct), now);
    if (questionLevel != level) return scheduled;

    final next = Mastery.next(MasteryState(level, levelStreak), correct: correct);
    return scheduled._withLevel(next, wasMastered: isMastered, now: now);
  }

  /// Manual override from the mastery slider: sets level and streak together from a score such as 2.5.
  SavedWord withProgress(double score, DateTime now) =>
      _withLevel(Mastery.stateForScore(score), wasMastered: isMastered, now: now);

  /// Feeds the mastered line on the stats chart.
  SavedWord _withLevel(MasteryState state, {required bool wasMastered, required DateTime now}) {
    final nowMastered = Mastery.isMastered(state.level);
    return copyWith(
      level: state.level,
      levelStreak: state.streak,
      masteredDate: nowMastered && !wasMastered ? now : null,
      clearMasteredDate: !nowMastered,
    );
  }
}
