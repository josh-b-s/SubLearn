import '../../models/quiz/quiz_column.dart';
import 'candidate.dart';

/// Pinyin options. Tapping one says the word it belongs to, since the voice can't read pinyin.
QuizColumn pinyinColumn({required Candidate target, required List<Candidate> wrong}) {
  final all = [target, ...wrong];
  return QuizColumn(
    title: 'PINYIN',
    choices: all.map((c) => c.pinyin).toList()..shuffle(),
    answer: target.pinyin,
    spoken: {for (final c in all.reversed) c.pinyin: c.word},
  );
}

QuizColumn meaningColumn({required Candidate target, required List<Candidate> wrong}) => QuizColumn(
      title: 'MEANING',
      choices: [target, ...wrong].map((c) => c.meaningText).toList()..shuffle(),
      answer: target.meaningText,
    );

QuizColumn wordColumn({required Candidate target, required List<Candidate> wrong}) => QuizColumn(
      title: 'WORD',
      choices: [target, ...wrong].map((c) => c.word).toList()..shuffle(),
      answer: target.word,
    );
