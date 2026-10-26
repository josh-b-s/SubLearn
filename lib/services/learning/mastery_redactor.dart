import '../../models/word_token.dart';
import 'mastery.dart';

/// Flags word cards whose meaning or pinyin the learner has outgrown.
abstract final class MasteryRedactor {
  static List<WordToken> apply(List<WordToken> tokens, Map<String, int> levels) {
    return [
      for (final token in tokens)
        if (levels[token.text] case final level?)
          token.copyWith(
            hideMeaning: !Mastery.showsMeaning(level),
            hidePinyin: !Mastery.showsPinyin(level),
          )
        else
          token,
    ];
  }
}
