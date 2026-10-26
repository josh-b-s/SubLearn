/// One column of answer options with its right answer.
class QuizColumn {
  const QuizColumn({
    required this.title,
    required this.choices,
    required this.answer,
    this.spoken = const {},
  });

  final String title;
  final List<String> choices;
  final String answer;

  /// Choice to the word the voice says when it's tapped. Others stay silent.
  final Map<String, String> spoken;

  QuizColumn shuffled() =>
      QuizColumn(title: title, choices: [...choices]..shuffle(), answer: answer, spoken: spoken);
}
