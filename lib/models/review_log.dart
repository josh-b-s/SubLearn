/// One first-attempt quiz answer. Feeds the stats screen.
class ReviewLog {
  const ReviewLog({required this.word, required this.correct, required this.date});

  final String word;
  final bool correct;
  final DateTime date;

  factory ReviewLog.fromJson(Map<String, dynamic> json) => ReviewLog(
        word: json['word'] as String,
        correct: json['correct'] as bool,
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {'word': word, 'correct': correct, 'date': date.toIso8601String()};
}
