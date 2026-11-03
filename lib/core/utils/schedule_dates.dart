/// Monday-based date for a weekly timetable entry, including Sunday.
DateTime scheduleDateForWeekday(DateTime reference, String weekday) {
  const days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  final index = days.indexOf(weekday.toLowerCase());
  if (index < 0) {
    throw ArgumentError.value(weekday, 'weekday', 'Unknown weekday');
  }
  return DateTime(
    reference.year,
    reference.month,
    reference.day - (reference.weekday - DateTime.monday) + index,
  );
}
