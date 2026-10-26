import '../../models/dictionary_match.dart';
import 'chinese_dictionary.dart';
import 'pinyin_key.dart';

final _asciiLetters = RegExp(r'^[a-z]+$');

extension DictionarySearch on ChineseDictionary {
  /// Finds words by Chinese text, pinyin or English meaning. Exact and prefix matches rank first,
  /// custom words win ties, then shorter words.
  List<DictionaryMatch> search(String query, {int limit = 50}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final key = q.pinyinKey;
    final pinyinQuery = _asciiLetters.hasMatch(key) ? key : null;

    final hits = <(int, DictionaryMatch)>[];
    forEachEntry((word, entry, isCustom, pinyinKey) {
      final score = _score(q, pinyinQuery, word, pinyinKey, entry.meanings);
      if (score != null) hits.add((score, DictionaryMatch(word: word, entry: entry, isCustom: isCustom)));
    });

    hits.sort((a, b) {
      if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
      if (a.$2.isCustom != b.$2.isCustom) return a.$2.isCustom ? -1 : 1;
      final lengthA = a.$2.word.runes.length;
      final lengthB = b.$2.word.runes.length;
      if (lengthA != lengthB) return lengthA.compareTo(lengthB);
      return a.$2.word.compareTo(b.$2.word);
    });
    return hits.take(limit).map((h) => h.$2).toList();
  }
}

/// Lower is better, null is no match. Pinyin sits between exact and partial English matches,
/// because short syllables like "he" are also English words.
int? _score(String q, String? pinyinQuery, String word, String pinyinKey, List<String> meanings) {
  if (word == q) return 0;
  if (word.startsWith(q)) return 1;
  if (word.contains(q)) return 2;
  if (meanings.contains(q)) return 3;
  if (pinyinQuery != null) {
    if (pinyinKey == pinyinQuery) return 4;
    if (pinyinKey.startsWith(pinyinQuery)) return 5;
  }
  if (meanings.any((m) => m.startsWith(q))) return 6;
  if (meanings.any((m) => m.contains(q))) return 7;
  return null;
}
