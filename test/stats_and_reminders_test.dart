import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/models/review_log.dart';
import 'package:subtitle_learn/models/saved_word.dart';
import 'package:subtitle_learn/models/stats_period.dart';
import 'package:subtitle_learn/models/stats_snapshot.dart';
import 'package:subtitle_learn/services/dates.dart';
import 'package:subtitle_learn/services/learning/mastery.dart';
import 'package:subtitle_learn/services/reminders/reminder_planner.dart';
import 'package:subtitle_learn/services/stats/stats_calculator.dart';

// A Sunday, in UTC so results don't depend on the device.
final now = DateTime.utc(2026, 10, 18, 12);

ReviewLog log({String word = 'w', bool correct = true, required int daysAgo}) =>
    ReviewLog(word: word, correct: correct, date: addDays(now, -daysAgo));

StatsSnapshot stats(List<ReviewLog> logs, {List<SavedWord> saved = const [], StatsPeriod period = StatsPeriod.all}) =>
    StatsCalculator.snapshot(logs: logs, saved: saved, period: period, now: now);

SavedWord saved(int daysAgo, {int level = 1, DateTime? masteredDate}) => SavedWord.fresh(
      word: 'w$daysAgo',
      pinyin: '',
      meanings: const [],
      now: addDays(now, -daysAgo),
    ).copyWith(level: level, masteredDate: masteredDate);

void main() {
  group('stats', () {
    test('empty data gives zeros and no accuracy', () {
      final s = stats([]);
      expect(s.reviews, 0);
      expect(s.accuracy, isNull);
      expect(s.streak, 0);
      expect(s.weekly.last.learned, 0);
    });
    test('streak counts consecutive days including today', () {
      expect(stats([log(daysAgo: 0), log(daysAgo: 1), log(daysAgo: 2)]).streak, 3);
    });
    test('streak survives a day with no review yet', () {
      expect(stats([log(daysAgo: 1), log(daysAgo: 2)]).streak, 2);
    });
    test('gap ends the streak', () => expect(stats([log(daysAgo: 0), log(daysAgo: 2)]).streak, 1));
    test('streak is zero after two missed days', () {
      expect(stats([log(daysAgo: 2), log(daysAgo: 3)]).streak, 0);
    });
    test('period limits reviews and accuracy', () {
      final logs = [log(daysAgo: 2), log(correct: false, daysAgo: 3), log(correct: false, daysAgo: 20)];
      final week = stats(logs, period: StatsPeriod.week);
      expect(week.reviews, 2);
      expect(week.correct, 1);
      expect(week.accuracy, 0.5);
      expect(stats(logs, period: StatsPeriod.month).reviews, 3);
      expect(stats(logs).reviews, 3);
    });
    test('daily counts group by day and ignore old reviews', () {
      final s = stats([log(daysAgo: 1), log(daysAgo: 1), log(daysAgo: 0)]);
      expect(s.dailyCounts[startOfDay(addDays(now, -1))], 2);
      expect(stats([log(daysAgo: StatsCalculator.heatmapDays + 5)]).dailyCounts, isEmpty);
    });
    test('a word counts as learned once and only when correct', () {
      final s = stats([
        log(word: 'a', daysAgo: 10),
        log(word: 'a', daysAgo: 1),
        log(word: 'b', correct: false, daysAgo: 1),
        log(word: 'c', daysAgo: 1),
      ]);
      expect(s.learnedThisWeek, 1);
      expect(s.weekly.length, StatsCalculator.chartWeeks);
      expect(s.weekly.last.learned, 2);
    });
    test('saved and mastered are running totals', () {
      final weekly = stats([], saved: [
        saved(200),
        saved(1, level: Mastery.masteredLevel, masteredDate: addDays(now, -1)),
      ]).weekly;
      expect(weekly.first.saved, 1);
      expect(weekly.first.mastered, 0);
      expect(weekly.last.saved, 2);
      expect(weekly.last.mastered, 1);
    });
    test('mastered without a date counts from the day it was added', () {
      expect(stats([], saved: [saved(200, level: Mastery.masteredLevel)]).weekly.first.mastered, 1);
    });
  });

  group('reminders', () {
    const evening = 19 * 60;
    List<Reminder> plan(List<DateTime> due, {int minutes = evening}) =>
        ReminderPlanner.plan(dueDates: due, minutesAfterMidnight: minutes, now: now);

    test('nothing due gives no reminders', () => expect(plan([]), isEmpty));
    test('overdue words remind every day in the horizon', () {
      final r = plan([addDays(now, -3)]);
      expect(r.length, ReminderPlanner.horizonDays);
      expect([r[0].fireDate.day, r[0].fireDate.hour, r[0].fireDate.minute], [18, 19, 0]);
    });
    test('count grows as more words fall due', () {
      final r = plan([addDays(now, -1), addDays(now, 1)]);
      expect(r[0].dueCount, 1);
      expect(r[1].dueCount, 2);
    });
    test('days before any word is due are skipped', () {
      expect(plan([addDays(now, 3)])[0].fireDate.day, 21);
    });
    test('today is skipped once the time has passed', () {
      final first = plan([addDays(now, -1)], minutes: 8 * 60)[0].fireDate;
      expect([first.day, first.hour], [19, 8]);
    });
  });
}
