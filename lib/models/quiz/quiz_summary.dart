/// End-of-quiz totals. Retries are not counted, only first attempts.
class QuizSummary {
  const QuizSummary({
    required this.attempted,
    required this.correctFirstTry,
    required this.leveledUp,
    required this.mastered,
  });

  final int attempted;
  final int correctFirstTry;
  final int leveledUp;
  final int mastered;

  String get text {
    final parts = ['$correctFirstTry of $attempted right on the first try.'];
    if (leveledUp > 0) parts.add('$leveledUp word${leveledUp == 1 ? '' : 's'} moved up a level.');
    if (mastered > 0) parts.add('$mastered mastered.');
    return parts.join(' ');
  }
}
