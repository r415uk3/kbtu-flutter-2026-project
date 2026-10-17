const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String twoDigits(int n) => n.toString().padLeft(2, '0');

// 18 Oct
String formatDay(DateTime date) => '${date.day} ${_months[date.month - 1]}';

// 10:00
String formatTime(int hour, int minute) =>
    '${twoDigits(hour)}:${twoDigits(minute)}';

// 18 Oct, 10:00
String formatDate(DateTime date) =>
    '${formatDay(date)}, ${formatTime(date.hour, date.minute)}';

// 2d 5h, 3h 07m or 12 min
String formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${twoDigits(d.inMinutes % 60)}m';
  return '${d.inMinutes} min';
}
