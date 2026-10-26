import '../../models/saved_word.dart';
import '../dictionary/pinyin_key.dart';

extension SavedWordSearch on SavedWord {
  /// Matches word, pinyin or meaning. Pinyin ignores case, tone marks and spaces, so "xi huan" finds "xǐhuān".
  bool matches(String query) {
    final q = query.trim();
    if (q.isEmpty) return true;
    final key = q.pinyinKey;
    final folded = foldDiacritics(q);
    return word.contains(q) ||
        (key.isNotEmpty && pinyin.pinyinKey.contains(key)) ||
        meanings.any((m) => foldDiacritics(m).contains(folded));
  }
}
