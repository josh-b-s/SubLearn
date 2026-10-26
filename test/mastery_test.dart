import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/models/mastery_filter.dart';
import 'package:subtitle_learn/models/mastery_status.dart';
import 'package:subtitle_learn/services/learning/mastery.dart';

void main() {
  test('first correct answer builds a streak', () {
    expect(Mastery.next(const MasteryState(1, 0), correct: true), const MasteryState(1, 1));
  });
  test('second correct in a row promotes', () {
    expect(Mastery.next(const MasteryState(1, 1), correct: true), const MasteryState(2, 0));
  });
  test('miss after a pass undoes the pass', () {
    expect(Mastery.next(const MasteryState(3, 1), correct: false), const MasteryState(3, 0));
  });
  test('miss at the start of a level drops halfway through the level below', () {
    expect(Mastery.next(const MasteryState(3, 0), correct: false), const MasteryState(2, 1));
  });
  test('miss at level 1 stays at level 1', () {
    expect(Mastery.next(const MasteryState(1, 0), correct: false), const MasteryState(1, 0));
    expect(Mastery.next(const MasteryState(1, 1), correct: false).level, 1);
  });
  test('label shows half steps', () {
    expect(Mastery.label(3, 0), '3');
    expect(Mastery.label(2, 1), '2.5');
    expect(Mastery.label(1, 0), '1');
  });
  test('score maps back to level and streak', () {
    expect(Mastery.stateForScore(2.5), const MasteryState(2, 1));
    expect(Mastery.stateForScore(3), const MasteryState(3, 0));
    expect(Mastery.stateForScore(4), const MasteryState(4, 0));
    expect(Mastery.stateForScore(99).level, Mastery.masteredLevel);
  });
  test('summary names the top score mastered', () {
    expect(Mastery.summaryForScore(2.5), 'Level 2.5');
    expect(Mastery.summaryForScore(4), 'Mastered');
  });
  test('passing level 3 masters the word', () {
    expect(Mastery.next(const MasteryState(3, 1), correct: true).level, Mastery.masteredLevel);
  });
  test('mastered word never changes', () {
    for (final correct in [true, false]) {
      expect(Mastery.next(const MasteryState(4, 0), correct: correct), const MasteryState(4, 0));
    }
  });
  test('quality rises with level', () {
    for (var l = 1; l <= 3; l++) {
      expect(Mastery.quality(l, correct: false), 1);
    }
    expect([1, 2, 3].map((l) => Mastery.quality(l, correct: true)), [3, 4, 5]);
  });
  test('hints hide as level rises', () {
    expect(Mastery.showsMeaning(1), isTrue);
    expect(Mastery.showsMeaning(2), isFalse);
    expect(Mastery.showsPinyin(2), isTrue);
    expect(Mastery.showsPinyin(3), isFalse);
  });
  test('status groups levels', () {
    expect(MasteryStatus.ofLevel(1), MasteryStatus.newWord);
    expect(MasteryStatus.ofLevel(2), MasteryStatus.learning);
    expect(MasteryStatus.ofLevel(3), MasteryStatus.learning);
    expect(MasteryStatus.ofLevel(4), MasteryStatus.mastered);
  });
  test('each level matches exactly one filter', () {
    for (var level = 1; level <= Mastery.masteredLevel; level++) {
      expect(MasteryFilter.values.where((f) => f.matches(level)).length, 1);
    }
  });
}
