/// Calendar-day helpers that keep the UTC flag, so tests can run on a fixed clock.
DateTime startOfDay(DateTime d) =>
    d.isUtc ? DateTime.utc(d.year, d.month, d.day) : DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int days) => d.isUtc
    ? DateTime.utc(d.year, d.month, d.day + days, d.hour, d.minute, d.second, d.millisecond)
    : DateTime(d.year, d.month, d.day + days, d.hour, d.minute, d.second, d.millisecond);

/// Monday-first week start.
DateTime startOfWeek(DateTime d) {
  final day = startOfDay(d);
  return addDays(day, -(day.weekday - DateTime.monday));
}

DateTime atTime(DateTime day, int hour, int minute) => day.isUtc
    ? DateTime.utc(day.year, day.month, day.day, hour, minute)
    : DateTime(day.year, day.month, day.day, hour, minute);
