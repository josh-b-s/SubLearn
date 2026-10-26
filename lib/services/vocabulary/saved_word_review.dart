import '../../models/saved_word.dart';
import '../dates.dart';
import '../learning/spaced_repetition.dart';

extension SavedWordReview on SavedWord {
  bool isDue(DateTime now) => !dueDate.isAfter(addDays(startOfDay(now), 1));

  /// Applies one SM-2 review and moves the due date.
  SavedWord reviewed(int quality, DateTime now) {
    final next = SpacedRepetition.next(
      SrsState(repetitions: repetitions, easeFactor: easeFactor, intervalDays: intervalDays),
      quality,
    );
    return copyWith(
      repetitions: next.repetitions,
      easeFactor: next.easeFactor,
      intervalDays: next.intervalDays,
      dueDate: addDays(now, next.intervalDays),
    );
  }
}
