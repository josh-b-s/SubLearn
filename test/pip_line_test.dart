import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/models/session/pip_line.dart';
import 'package:subtitle_learn/models/word_token.dart';

void main() {
  test('fromJson reads what toJson wrote', () {
    const line = PipLine(id: 3, tokens: [
      WordToken(id: 0, text: '学习', pinyin: 'xuéxí', meanings: ['study', 'learn'], hidePinyin: true),
      WordToken(id: 1, text: '中文', pinyin: 'zhōngwén', meanings: ['Chinese language'], hideMeaning: true),
    ]);

    final copy = PipLine.fromJson(Map<String, Object?>.from(line.toJson()));

    expect(copy.id, 3);
    expect(copy.tokens.map((t) => t.text), ['学习', '中文']);
    expect(copy.tokens[0].meanings, ['study', 'learn']);
    expect(copy.tokens[0].hidePinyin, isTrue);
    expect(copy.tokens[1].hideMeaning, isTrue);
  });
}
