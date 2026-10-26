import 'dart:math';

import '../dictionary/chinese_dictionary.dart';
import '../dictionary/han.dart';
import 'candidate.dart';

/// Chooses plausible wrong options: other saved words first, dictionary words to fill.
class DistractorPicker {
  DistractorPicker({required this.saved, required this.dictionary, Random? random})
      : _random = random ?? Random();

  final List<Candidate> saved;
  final ChineseDictionary? dictionary;
  final Random _random;

  List<Candidate> pick(Candidate target, {int count = 3}) {
    final length = runeLength(target.word);
    final targetMeanings = target.meanings.toSet();
    final picked = <Candidate>[];

    void consider(Candidate c) {
      if (picked.length >= count ||
          c.word == target.word ||
          c.pinyin == target.pinyin ||
          c.meanings.isEmpty ||
          c.meanings.any(targetMeanings.contains)) {
        return;
      }
      final clash = picked.any(
        (p) => p.word == c.word || p.pinyin == c.pinyin || p.meaningText == c.meaningText,
      );
      if (!clash) picked.add(c);
    }

    // Same length first so options look alike.
    final sameLength = saved.where((c) => runeLength(c.word) == length).toList()..shuffle(_random);
    final others = saved.where((c) => runeLength(c.word) != length).toList()..shuffle(_random);
    for (final c in [...sameLength, ...others]) {
      consider(c);
    }

    final dict = dictionary;
    if (picked.length < count && dict != null) {
      final extra = dict.sample(count: (count - picked.length) * 4, length: length, random: _random);
      for (final (word, entry) in extra) {
        consider(Candidate(word: word, pinyin: entry.pinyin, meanings: entry.meanings));
      }
    }
    return picked;
  }
}
