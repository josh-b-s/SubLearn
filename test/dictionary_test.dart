import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/models/dictionary_entry.dart';
import 'package:subtitle_learn/services/dictionary/chinese_dictionary.dart';
import 'package:subtitle_learn/services/dictionary/dictionary_search.dart';
import 'package:subtitle_learn/services/dictionary/pinyin_key.dart';
import 'package:subtitle_learn/services/dictionary/short_meanings.dart';

DictionaryEntry entry(String pinyin, List<String> meanings) => DictionaryEntry(pinyin: pinyin, meanings: meanings);

void main() {
  group('shortMeanings', () {
    test('strips to prefix, notes and duplicates', () {
      expect(shortMeanings('to eat/to consume (formal)/Eat/food'), ['eat', 'consume', 'food']);
    });
    test('keeps at most three', () => expect(shortMeanings('a/b/c/d/e'), ['a', 'b', 'c']));
    test('splits on semicolons and commas', () => expect(shortMeanings('big; large, huge'), ['big', 'large', 'huge']));
    test('capitalises lone I', () => expect(shortMeanings('i'), ['I']));
    test('empty gives nothing', () => expect(shortMeanings(''), isEmpty));
  });

  group('segmentation', () {
    final dictionary = ChineseDictionary(entries: {
      '喜欢': entry('xǐhuan', ['to like']),
      '学习': entry('xuéxí', ['to study']),
      '学习中文': entry('xuéxízhōngwén', ['to study Chinese']),
      '中文': entry('zhōngwén', ['Chinese']),
    });

    test('splits a sentence into dictionary words', () => expect(dictionary.segment('喜欢中文'), ['喜欢', '中文']));
    test('prefers the longest match', () => expect(dictionary.segment('学习中文'), ['学习中文']));
    test('unknown characters become single words', () => expect(dictionary.segment('我们'), ['我', '们']));
    test('skips latin, digits and punctuation', () => expect(dictionary.segment('hi 喜欢, 123!'), ['喜欢']));
    test('empty input gives no words', () => expect(dictionary.segment(''), isEmpty));
    test('tokens carry meanings and position ids', () {
      final tokens = dictionary.tokens('喜欢我');
      expect(tokens.map((t) => t.id), [0, 1]);
      expect(tokens[0].meanings, ['to like']);
      expect(tokens[0].pinyin, 'xǐhuan');
    });
    test('unknown word has no meanings', () => expect(dictionary.tokens('我')[0].meanings, isEmpty));
    test('custom entry overrides bundled one', () {
      final custom = dictionary.withCustom({'中文': entry('zhongwen', ['my meaning'])});
      expect(custom.entry('中文')?.meanings, ['my meaning']);
    });
    test('fallback pinyin joins character entries', () {
      final d = ChineseDictionary(entries: {'我': entry('wǒ', ['I']), '们': entry('men', ['plural'])});
      expect(d.fallbackPinyin('我们'), 'wǒmen');
    });
  });

  group('search', () {
    final dictionary = ChineseDictionary(entries: {
      '喜欢': entry('xǐhuan', ['like']),
      '洗': entry('xǐ', ['wash']),
      '是': entry('shì', ['be']),
      '母鸡': entry('mǔjī', ['hen']),
      '和': entry('hé', ['and']),
      '他': entry('tā', ['he']),
    });

    test('key ignores case, tones and spaces', () => expect('Xǐ Huan'.pinyinKey, 'xihuan'));
    test('finds by pinyin without tones', () => expect(dictionary.search('shi').map((m) => m.word), ['是']));
    test('spaces in query are ignored', () => expect(dictionary.search('xi huan').map((m) => m.word), ['喜欢']));
    test('exact pinyin ranks before prefix', () => expect(dictionary.search('xi').map((m) => m.word), ['洗', '喜欢']));
    test('exact English ranks before pinyin', () {
      expect(dictionary.search('he').map((m) => m.word), ['他', '和', '母鸡']);
    });
  });
}
