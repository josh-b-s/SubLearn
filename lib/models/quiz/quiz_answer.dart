/// What the learner picked.
sealed class QuizAnswer {
  const QuizAnswer();
}

final class ChoiceAnswer extends QuizAnswer {
  const ChoiceAnswer(this.choice);
  final String choice;
}

final class PairAnswer extends QuizAnswer {
  const PairAnswer({required this.first, required this.second});
  final String first;
  final String second;
}

final class ClozeAnswer extends QuizAnswer {
  const ClozeAnswer({required this.word, required this.pinyin, required this.meaning});
  final String word;
  final String pinyin;
  final String meaning;
}
