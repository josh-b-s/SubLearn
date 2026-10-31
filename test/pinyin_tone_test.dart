import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/services/pinyin/pinyin_tone.dart';

void main() {
  test('finds the tone and the marked vowel', () {
    expect(toneMark('mā'), (tone: Tone.first, index: 1));
    expect(toneMark('má'), (tone: Tone.second, index: 1));
    expect(toneMark('hǎo'), (tone: Tone.third, index: 1));
    expect(toneMark('xià'), (tone: Tone.fourth, index: 2));
  });

  test('reads marks on ü and uppercase', () {
    expect(toneMark('nǚ')?.tone, Tone.third);
    expect(toneMark('Lǜ')?.tone, Tone.fourth);
  });

  test('no mark returns null', () {
    expect(toneMark('ma'), isNull);
    expect(toneMark('nü'), isNull);
    expect(toneMark(''), isNull);
  });
}
