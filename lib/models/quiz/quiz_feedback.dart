/// Shown after each answer.
class QuizFeedback {
  const QuizFeedback({
    required this.correct,
    required this.answerText,
    required this.explanation,
    this.levelNote,
  });

  final bool correct;
  final String answerText;

  /// One line on why the answer is right, shown after a correct answer.
  final String explanation;

  /// Set when the word moved level on this answer.
  final String? levelNote;
}
