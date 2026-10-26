import 'progress_series.dart';

/// One week on the progress chart. Each count is a running total up to the end of that week.
class WeeklyProgress {
  const WeeklyProgress({
    required this.weekStart,
    required this.learned,
    required this.saved,
    required this.mastered,
  });

  final DateTime weekStart;
  final int learned;
  final int saved;
  final int mastered;

  int value(ProgressSeries series) => switch (series) {
        ProgressSeries.learned => learned,
        ProgressSeries.saved => saved,
        ProgressSeries.mastered => mastered,
      };
}

/// Everything the stats screen displays.
class StatsSnapshot {
  const StatsSnapshot({
    required this.streak,
    required this.reviews,
    required this.correct,
    required this.dailyCounts,
    required this.weekly,
  });

  final int streak;

  /// First-try answers in the selected period, and how many were right.
  final int reviews;
  final int correct;

  /// Reviews per day (keyed by start of day) for the heatmap window.
  final Map<DateTime, int> dailyCounts;
  final List<WeeklyProgress> weekly;

  double? get accuracy => reviews == 0 ? null : correct / reviews;

  int get learnedThisWeek {
    if (weekly.isEmpty) return 0;
    final previous = weekly.length > 1 ? weekly[weekly.length - 2].learned : 0;
    return weekly.last.learned - previous;
  }
}
