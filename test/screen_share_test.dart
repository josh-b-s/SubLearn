import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/models/saved_word.dart';
import 'package:subtitle_learn/models/session/session_entry.dart';
import 'package:subtitle_learn/models/word_token.dart';
import 'package:subtitle_learn/services/screen_share/pip_subtitle_model.dart';
import 'package:subtitle_learn/services/screen_share/session_summary_builder.dart';
import 'package:subtitle_learn/services/screen_share/session_word_tracker.dart';

WordToken token(String text, {List<String> meanings = const ['meaning']}) =>
    WordToken(id: 0, text: text, pinyin: text, meanings: meanings);

SavedWord savedWord(String word, {int level = 1}) =>
    SavedWord.fresh(word: word, pinyin: '', meanings: const ['m'], now: DateTime.utc(2026, 10, 18)).copyWith(level: level);

int countOf(SessionWordTracker tracker, String word) =>
    tracker.entries.where((e) => e.token.text == word).map((e) => e.count).firstOrNull ?? 0;

void main() {
  group('SessionWordTracker', () {
    test('partials are not counted', () {
      final tracker = SessionWordTracker()..update([token('你好')], isFinal: false);
      expect(tracker.entries, isEmpty);
    });

    test('a final result counts each word once, however many partials came first', () {
      final tracker = SessionWordTracker()
        ..update([token('你')], isFinal: false)
        ..update([token('你'), token('好')], isFinal: false)
        ..update([token('你'), token('好')], isFinal: true);
      expect(countOf(tracker, '你'), 1);
      expect(countOf(tracker, '好'), 1);
    });

    test('hearing a word again adds to its count', () {
      final tracker = SessionWordTracker()
        ..update([token('你好')], isFinal: true)
        ..update([token('你好'), token('谢谢')], isFinal: true);
      expect(countOf(tracker, '你好'), 2);
      expect(countOf(tracker, '谢谢'), 1);
    });

    test('words without a meaning are skipped', () {
      final tracker = SessionWordTracker()..update([token('啊', meanings: const [])], isFinal: true);
      expect(tracker.entries, isEmpty);
    });

    test('flush counts an unfinished utterance', () {
      final tracker = SessionWordTracker()
        ..update([token('你好')], isFinal: false)
        ..flush();
      expect(countOf(tracker, '你好'), 1);
    });

    test('flush twice does not count twice', () {
      final tracker = SessionWordTracker()
        ..update([token('你好')], isFinal: false)
        ..flush()
        ..flush();
      expect(countOf(tracker, '你好'), 1);
    });

    test('reset clears counts and the pending utterance', () {
      final tracker = SessionWordTracker()
        ..update([token('你好')], isFinal: true)
        ..update([token('谢谢')], isFinal: false)
        ..reset()
        ..flush();
      expect(tracker.entries, isEmpty);
    });
  });

  group('SessionSummaryBuilder', () {
    SessionEntry entry(String word, int count) => SessionEntry(token: token(word), count: count);

    test('no entries gives no summary', () {
      expect(SessionSummaryBuilder.build(const [], const []), isNull);
    });

    test('splits words into known, learning and new', () {
      final summary = SessionSummaryBuilder.build(
        [entry('a', 1), entry('b', 1), entry('c', 1), entry('d', 1)],
        [savedWord('a', level: 4), savedWord('b', level: 2)],
      )!;
      expect(summary.alreadyKnown, 1);
      expect(summary.learning, 1);
      expect(summary.newWords, 2);
      expect(summary.total, 4);
    });

    test('top words leave out mastered ones and sort by count, then text', () {
      final summary = SessionSummaryBuilder.build(
        [entry('b', 2), entry('a', 2), entry('c', 5), entry('m', 9)],
        [savedWord('m', level: 4)],
      )!;
      expect(summary.topWords.map((e) => e.token.text), ['c', 'a', 'b']);
    });

    test('keeps at most eight top words', () {
      final entries = [for (var i = 0; i < 12; i++) entry('w$i', i + 1)];
      final summary = SessionSummaryBuilder.build(entries, const [])!;
      expect(summary.topWords, hasLength(SessionSummaryBuilder.maxTopWords));
      expect(summary.topWords.first.token.text, 'w11');
    });

    test('unsaved top words exclude saved ones', () {
      final summary = SessionSummaryBuilder.build(
        [entry('a', 3), entry('b', 2)],
        [savedWord('a')],
      )!;
      expect(summary.unsavedTopWords, {'b'});
    });
  });

  group('PipSubtitleModel', () {
    List<WordToken> words(List<String> texts) => [for (final t in texts) token(t)];

    test('a partial shows as a line after the finished ones', () {
      final model = PipSubtitleModel()
        ..update(words(['你好']), isFinal: true, levels: const {}, hideLearned: false)
        ..update(words(['谢谢']), isFinal: false, levels: const {}, hideLearned: false);
      expect(model.lines.map((l) => l.tokens.first.text), ['你好', '谢谢']);
    });

    test('a final result becomes a finished line and the next utterance gets a new one', () {
      final model = PipSubtitleModel()
        ..update(words(['你好']), isFinal: true, levels: const {}, hideLearned: false)
        ..update(words(['谢谢']), isFinal: true, levels: const {}, hideLearned: false);
      expect(model.lines, hasLength(2));
      expect(model.lines[0].id, isNot(model.lines[1].id));
    });

    test('an empty update drops the partial and keeps finished lines', () {
      final model = PipSubtitleModel()
        ..update(words(['你好']), isFinal: true, levels: const {}, hideLearned: false)
        ..update(words(['谢谢']), isFinal: false, levels: const {}, hideLearned: false)
        ..update(const [], isFinal: false, levels: const {}, hideLearned: false);
      expect(model.lines, hasLength(1));
    });

    test('drops the oldest lines once past the card cap', () {
      final model = PipSubtitleModel();
      for (var i = 0; i < 6; i++) {
        model.update(words([for (var j = 0; j < 10; j++) 'w$i$j']), isFinal: true, levels: const {}, hideLearned: false);
      }
      final total = model.lines.fold(0, (sum, l) => sum + l.tokens.length);
      expect(total, lessThanOrEqualTo(PipSubtitleModel.maxTokens));
      expect(model.lines.last.tokens.first.text, 'w50');
    });

    test('hides hints for learned words only when asked', () {
      final shown = PipSubtitleModel()..update(words(['你好']), isFinal: false, levels: const {'你好': 4}, hideLearned: false);
      final hidden = PipSubtitleModel()..update(words(['你好']), isFinal: false, levels: const {'你好': 4}, hideLearned: true);
      expect(shown.lines.single.tokens.single.hideMeaning, isFalse);
      expect(hidden.lines.single.tokens.single.hideMeaning, isTrue);
    });

    test('clear removes everything', () {
      final model = PipSubtitleModel()
        ..update(words(['你好']), isFinal: true, levels: const {}, hideLearned: false)
        ..clear();
      expect(model.lines, isEmpty);
    });
  });
}
