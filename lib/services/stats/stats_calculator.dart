import '../../models/review_log.dart';
import '../../models/saved_word.dart';
import '../../models/stats_period.dart';
import '../../models/stats_snapshot.dart';
import '../dates.dart';
import '../vocabulary/saved_word_mastery.dart';

/// Turns the review log and saved words into the numbers on the stats screen.
abstract final class StatsCalculator {
  static const heatmapDays = 90;
  static const chartWeeks = 12;

  static StatsSnapshot snapshot({
    required List<ReviewLog> logs,
    required List<SavedWord> saved,
    required StatsPeriod period,
    required DateTime now,
  }) {
    final today = startOfDay(now);
    final days = period.days;
    final cutoff = days == null ? null : addDays(now, -days);
    final inPeriod = cutoff == null ? logs : logs.where((l) => !l.date.isBefore(cutoff)).toList();

    return StatsSnapshot(
      streak: streak(logs, today),
      reviews: inPeriod.length,
      correct: inPeriod.where((l) => l.correct).length,
      dailyCounts: _dailyCounts(logs, today),
      weekly: _weeklyProgress(logs, saved, today),
    );
  }

  /// Consecutive days with a review. A day with no review yet today doesn't break the streak.
  static int streak(List<ReviewLog> logs, DateTime today) {
    final days = {for (final l in logs) startOfDay(l.date)};
    var day = today;
    if (!days.contains(day)) day = addDays(day, -1);
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = addDays(day, -1);
    }
    return count;
  }

  static Map<DateTime, int> _dailyCounts(List<ReviewLog> logs, DateTime today) {
    final start = addDays(today, -(heatmapDays - 1));
    final counts = <DateTime, int>{};
    for (final log in logs) {
      final day = startOfDay(log.date);
      if (!day.isBefore(start)) counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
  }

  /// Running totals at the end of each of the last [chartWeeks] weeks. A word counts as learned
  /// on the day of its first correct answer, saved on the day it was added, mastered on its mastered date.
  static List<WeeklyProgress> _weeklyProgress(List<ReviewLog> logs, List<SavedWord> saved, DateTime today) {
    final firstCorrect = <String, DateTime>{};
    for (final log in logs.where((l) => l.correct)) {
      final existing = firstCorrect[log.word];
      if (existing == null || log.date.isBefore(existing)) firstCorrect[log.word] = log.date;
    }
    final learned = firstCorrect.values.toList();
    final savedDates = saved.map((w) => w.dateAdded).toList();
    // Words mastered before the date was tracked fall back to the day they were added.
    final mastered = saved.where((w) => w.isMastered).map((w) => w.masteredDate ?? w.dateAdded).toList();

    final firstWeek = addDays(startOfWeek(today), -7 * (chartWeeks - 1));
    return [
      for (var i = 0; i < chartWeeks; i++)
        () {
          final start = addDays(firstWeek, 7 * i);
          final end = addDays(start, 7);
          return WeeklyProgress(
            weekStart: start,
            learned: learned.where((d) => d.isBefore(end)).length,
            saved: savedDates.where((d) => d.isBefore(end)).length,
            mastered: mastered.where((d) => d.isBefore(end)).length,
          );
        }(),
    ];
  }
}
