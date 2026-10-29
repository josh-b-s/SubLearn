import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/services/speech/transcript_join.dart';

void main() {
  test('Chinese utterances join with no space', () {
    expect(joinTranscript('我喜欢', '学习中文'), '我喜欢学习中文');
  });

  test('Latin words get a space between utterances', () {
    expect(joinTranscript('hello', 'world'), 'hello world');
  });

  test('a space is not added next to Chinese text', () {
    expect(joinTranscript('我用', 'iPhone'), '我用iPhone');
    expect(joinTranscript('iPhone', '很好'), 'iPhone很好');
  });

  test('empty sides pass through', () {
    expect(joinTranscript('', '你好'), '你好');
    expect(joinTranscript('你好', ''), '你好');
  });
}
