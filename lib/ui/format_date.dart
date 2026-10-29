const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Three-letter English month name for a month number 1 to 12.
String monthAbbreviation(int month) => _months[month - 1];

String formatDay(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatDayTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '${formatDay(d)}, $hour:$minute ${d.hour < 12 ? 'am' : 'pm'}';
}

/// 12-hour clock time for minutes after midnight, such as 8:05 am.
String formatMinutes(int minutes) {
  final hour = minutes ~/ 60 % 12 == 0 ? 12 : minutes ~/ 60 % 12;
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute ${minutes ~/ 60 < 12 ? 'am' : 'pm'}';
}
