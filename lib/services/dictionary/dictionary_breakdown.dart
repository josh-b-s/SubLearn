import '../../models/char_gloss.dart';
import 'chinese_dictionary.dart';

extension DictionaryBreakdown on ChineseDictionary {
  /// Per-character gloss for words of 2+ characters. Characters not in the dictionary are skipped.
  List<CharGloss> breakdown(String word) {
    final chars = word.runes.map(String.fromCharCode).toList();
    if (chars.length < 2) return const [];
    return [
      for (var i = 0; i < chars.length; i++)
        if (entry(chars[i]) case final e?)
          CharGloss(
            id: i,
            char: chars[i],
            pinyin: e.pinyin,
            meaning: e.meanings.take(2).join(' / '),
          ),
    ];
  }
}
