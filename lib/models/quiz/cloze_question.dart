import '../word_token.dart';
import 'quiz_column.dart';

/// Level 3: a short sentence with the target word blanked out, plus its pinyin and meaning.
class ClozeQuestion {
  const ClozeQuestion({
    required this.before,
    required this.after,
    required this.translation,
    required this.choices,
    required this.answer,
    required this.pinyin,
    required this.meaning,
  });

  final List<WordToken> before;
  final List<WordToken> after;

  /// English clue so only the target word fits.
  final String translation;

  /// Word bank.
  final List<String> choices;
  final String answer;

  /// Pinyin of the answer, so a lucky word guess isn't enough.
  final QuizColumn pinyin;
  final QuizColumn meaning;
}
