import 'quiz_column.dart';

enum PairPrompt { word, meaning, audio }

/// Level 2 and the level 3 listening question: pick two parts that both belong to one word.
class PairQuestion {
  const PairQuestion({
    required this.prompt,
    required this.word,
    required this.pinyin,
    required this.meaning,
    required this.first,
    required this.second,
  });

  final PairPrompt prompt;

  /// The word being asked about, spoken for audio prompts.
  final String word;
  final String pinyin;
  final String meaning;

  /// The pinyin, or the word for the listening question.
  final QuizColumn first;

  /// The meaning, or the word when the prompt is the meaning.
  final QuizColumn second;
}
