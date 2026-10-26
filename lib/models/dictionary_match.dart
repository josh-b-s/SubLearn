import 'dictionary_entry.dart';
import 'word_token.dart';

/// A dictionary search hit.
class DictionaryMatch {
  const DictionaryMatch({required this.word, required this.entry, required this.isCustom});

  final String word;
  final DictionaryEntry entry;
  final bool isCustom;

  WordToken get token => WordToken(id: 0, text: word, pinyin: entry.pinyin, meanings: entry.meanings);
}
