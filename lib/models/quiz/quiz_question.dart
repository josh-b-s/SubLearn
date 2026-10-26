import 'choice_question.dart';
import 'cloze_question.dart';
import 'pair_question.dart';

sealed class QuizKind {
  const QuizKind();
}

final class ChoiceKind extends QuizKind {
  const ChoiceKind(this.question);
  final ChoiceQuestion question;
}

final class PairKind extends QuizKind {
  const PairKind(this.question);
  final PairQuestion question;
}

final class ClozeKind extends QuizKind {
  const ClozeKind(this.question);
  final ClozeQuestion question;
}

int _nextId = 0;

/// One question about one saved word, at the word's current level.
class QuizQuestion {
  QuizQuestion({required this.word, required this.level, required this.kind, this.isRetry = false})
      : id = _nextId++;

  final int id;

  /// The SavedWord.word this question reviews.
  final String word;

  /// Difficulty actually asked, which can be below the word's level on fallback.
  final int level;
  final QuizKind kind;

  /// Re-asked after a miss, never graded again.
  final bool isRetry;
}
