/// One question as it was asked, with the right answer and whether the first try got it.
class QuizRecordItem {
  const QuizRecordItem({required this.prompt, required this.answer, required this.correct});

  final String prompt;
  final String answer;
  final bool correct;

  factory QuizRecordItem.fromJson(Map<String, dynamic> json) => QuizRecordItem(
        prompt: json['prompt'] as String,
        answer: json['answer'] as String,
        correct: json['correct'] as bool,
      );

  Map<String, dynamic> toJson() => {'prompt': prompt, 'answer': answer, 'correct': correct};
}

/// One quiz run and the first-attempt result of each question in it.
class QuizRecord {
  const QuizRecord({required this.date, required this.items});

  final DateTime date;
  final List<QuizRecordItem> items;

  int get correctCount => items.where((i) => i.correct).length;

  QuizRecord withItem(QuizRecordItem item) => QuizRecord(date: date, items: [...items, item]);

  factory QuizRecord.fromJson(Map<String, dynamic> json) => QuizRecord(
        date: DateTime.parse(json['date'] as String),
        items: (json['items'] as List)
            .map((e) => QuizRecordItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() =>
      {'date': date.toIso8601String(), 'items': items.map((i) => i.toJson()).toList()};
}
