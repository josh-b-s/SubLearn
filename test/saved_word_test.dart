import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/models/mastery_filter.dart';
import 'package:subtitle_learn/models/review_log.dart';
import 'package:subtitle_learn/models/saved_word.dart';
import 'package:subtitle_learn/models/vocabulary_sort.dart';
import 'package:subtitle_learn/services/learning/mastery.dart';
import 'package:subtitle_learn/services/vocabulary/saved_word_mastery.dart';

final now = DateTime.utc(2026, 10, 18, 12);

SavedWord word({String text = '你好', int level = 1, int streak = 0}) =>
    SavedWord.fresh(word: text, pinyin: 'nǐhǎo', meanings: ['hello'], now: now).copyWith(level: level, levelStreak: streak);

void main() {
  test('matching question level can promote', () {
    final w = word(streak: 1).recorded(correct: true, questionLevel: 1, now: now);
    expect(w.level, 2);
    expect(w.levelStreak, 0);
  });
  test('miss loses half a level', () {
    expect(word(level: 3).recorded(correct: false, questionLevel: 3, now: now).masteryLabel, '2.5');
  });
  test('easier fallback question only affects the schedule', () {
    final w = word(level: 3, streak: 1).recorded(correct: false, questionLevel: 1, now: now);
    expect(w.level, 3);
    expect(w.levelStreak, 1);
    expect(w.repetitions, 0);
    expect(w.intervalDays, 1);
  });
  test('setProgress clamps to the valid range', () {
    expect(word().withProgress(9, now).level, Mastery.masteredLevel);
    final low = word().withProgress(-2, now);
    expect(low.level, 1);
    expect(low.levelStreak, 0);
  });
  test('setProgress sets level and streak', () {
    final w = word(streak: 1).withProgress(2.5, now);
    expect(w.level, 2);
    expect(w.levelStreak, 1);
    expect(w.withProgress(3, now).levelStreak, 0);
  });
  test('mastered date is set on mastery and cleared when it drops', () {
    final mastered = word().withProgress(4, now);
    expect(mastered.masteredDate, now);
    expect(mastered.withProgress(2, now).masteredDate, isNull);
  });
  test('mastered flag follows level', () {
    expect(word(level: 3).isMastered, isFalse);
    expect(word(level: 4).isMastered, isTrue);
  });
  test('filter and sort', () {
    expect(MasteryFilter.level2.matches(3), isFalse);
    final a = word(text: 'a'), b = word(text: 'b'), c = word(text: 'c');
    final logs = [
      ReviewLog(word: 'a', correct: true, date: now.subtract(const Duration(seconds: 500))),
      ReviewLog(word: 'a', correct: true, date: now.subtract(const Duration(seconds: 300))),
      ReviewLog(word: 'b', correct: false, date: now.subtract(const Duration(seconds: 100))),
    ];
    expect(VocabularySort.recentlyReviewed.sorted([a, b, c], logs).map((w) => w.word), ['b', 'a', 'c']);
    final misses = [
      ReviewLog(word: 'a', correct: false, date: now),
      ReviewLog(word: 'b', correct: false, date: now),
      ReviewLog(word: 'b', correct: false, date: now),
      ReviewLog(word: 'c', correct: true, date: now),
    ];
    expect(VocabularySort.mostMissed.sorted([a, b, c], misses).map((w) => w.word), ['b', 'a', 'c']);
  });
}
