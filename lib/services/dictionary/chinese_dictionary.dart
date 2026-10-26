import 'dart:math';

import '../../models/dictionary_entry.dart';
import '../../models/word_token.dart';
import 'han.dart';
import 'pinyin_key.dart';
import 'short_meanings.dart';

/// Bundled zh-en dictionary plus greedy longest-match segmentation.
class ChineseDictionary {
  ChineseDictionary({required Map<String, DictionaryEntry> entries, Map<String, DictionaryEntry> custom = const {}})
      : this._(entries, {for (final e in entries.entries) e.key: e.value.pinyin.pinyinKey}, custom);

  const ChineseDictionary._(this._entries, this._pinyinKeys, this._custom);

  static const _maxWordLength = 6;

  final Map<String, DictionaryEntry> _entries;

  /// Pinyin key of each bundled entry, so search doesn't refold 100k strings.
  final Map<String, String> _pinyinKeys;

  /// User-added words, which win over bundled ones.
  final Map<String, DictionaryEntry> _custom;

  /// Parses zh-en.tsv. Each line: word TAB meanings (slash separated) TAB pinyin.
  /// The first entry for a word wins. Runs in an isolate, so it takes a plain string.
  static ChineseDictionary parse(String tsv) {
    final entries = <String, DictionaryEntry>{};
    for (final line in tsv.split('\n')) {
      final parts = line.split('\t');
      if (parts.length < 2) continue;
      final word = parts[0].trim();
      if (word.isEmpty || entries.containsKey(word)) continue;
      final meanings = shortMeanings(parts[1]);
      if (meanings.isEmpty) continue;
      final pinyin = parts.length > 2 ? parts[2].replaceAll(' ', '').trim() : '';
      entries[word] = DictionaryEntry(pinyin: pinyin, meanings: meanings);
    }
    return ChineseDictionary(entries: entries);
  }

  /// Same bundled words with the user's custom words layered on top. Shares the big tables.
  ChineseDictionary withCustom(Map<String, DictionaryEntry> custom) =>
      ChineseDictionary._(_entries, _pinyinKeys, custom);

  DictionaryEntry? entry(String word) => _custom[word] ?? _entries[word];

  /// Visits every word, custom ones first.
  void forEachEntry(void Function(String word, DictionaryEntry entry, bool isCustom, String pinyinKey) visit) {
    _custom.forEach((word, entry) => visit(word, entry, true, entry.pinyin.pinyinKey));
    _entries.forEach((word, entry) {
      if (!_custom.containsKey(word)) visit(word, entry, false, _pinyinKeys[word] ?? '');
    });
  }

  List<String> segment(String text) {
    final chars = text.runes.toList();
    final words = <String>[];
    var i = 0;
    while (i < chars.length) {
      // Skips spaces, punctuation, latin letters and digits.
      if (!isHanRune(chars[i])) {
        i++;
        continue;
      }
      final limit = min(_maxWordLength, chars.length - i);
      var matched = 1;
      for (var length = limit; length >= 2; length--) {
        final slice = chars.sublist(i, i + length);
        if (slice.every(isHanRune) && entry(String.fromCharCodes(slice)) != null) {
          matched = length;
          break;
        }
      }
      words.add(String.fromCharCodes(chars.sublist(i, i + matched)));
      i += matched;
    }
    return words;
  }

  /// Random all-Han entries with exactly [length] characters, for quiz wrong options.
  List<(String, DictionaryEntry)> sample({required int count, required int length, Random? random}) {
    final rng = random ?? Random();
    final keys = _entries.keys.toList(growable: false);
    final result = <(String, DictionaryEntry)>[];
    final seen = <String>{};
    var attempts = 0;
    while (result.length < count && attempts < count * 60 && keys.isNotEmpty) {
      attempts++;
      final key = keys[rng.nextInt(keys.length)];
      if (runeLength(key) != length || !isAllHan(key) || !seen.add(key)) continue;
      result.add((key, _entries[key]!));
    }
    return result;
  }

  List<WordToken> tokens(String text) {
    final words = segment(text);
    return [
      for (var i = 0; i < words.length; i++)
        if (entry(words[i]) case final e?)
          WordToken(id: i, text: words[i], pinyin: e.pinyin, meanings: e.meanings)
        else
          WordToken(id: i, text: words[i], pinyin: fallbackPinyin(words[i]), meanings: const []),
    ];
  }

  /// Pinyin for a word that has no entry, built from its characters' own entries.
  String fallbackPinyin(String word) {
    final out = StringBuffer();
    for (final rune in word.runes) {
      final e = entry(String.fromCharCode(rune));
      if (e != null) out.write(e.pinyin);
    }
    return out.toString();
  }
}
