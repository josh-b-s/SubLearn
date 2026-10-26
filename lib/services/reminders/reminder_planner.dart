import '../dates.dart';

class Reminder {
  const Reminder({required this.fireDate, required this.dueCount});

  final DateTime fireDate;
  final int dueCount;
}

/// Works out which days get a review reminder and how many words each one mentions.
abstract final class ReminderPlanner {
  /// Platforms cap pending notifications, so plan a fortnight ahead and top up when the app opens or closes.
  static const horizonDays = 14;

  /// [dueDates] belong to words still being learned. As in `isDue`, a word counts for a day once it is
  /// due by the end of that day. Days with nothing due, and times already past, get no reminder.
  static List<Reminder> plan({
    required List<DateTime> dueDates,
    required int minutesAfterMidnight,
    required DateTime now,
  }) {
    final today = startOfDay(now);
    final reminders = <Reminder>[];
    for (var offset = 0; offset < horizonDays; offset++) {
      final day = addDays(today, offset);
      final nextDay = addDays(day, 1);
      final fireDate = atTime(day, minutesAfterMidnight ~/ 60, minutesAfterMidnight % 60);
      if (!fireDate.isAfter(now)) continue;
      final count = dueDates.where((d) => !d.isAfter(nextDay)).length;
      if (count > 0) reminders.add(Reminder(fireDate: fireDate, dueCount: count));
    }
    return reminders;
  }
}
