/// Window for the reviews and accuracy numbers.
enum StatsPeriod {
  week('7 days', 7),
  month('30 days', 30),
  all('All time', null);

  const StatsPeriod(this.label, this.days);
  final String label;

  /// Null means no cutoff.
  final int? days;
}
