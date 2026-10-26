const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String formatDay(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatDayTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '${formatDay(d)}, $hour:$minute ${d.hour < 12 ? 'am' : 'pm'}';
}
