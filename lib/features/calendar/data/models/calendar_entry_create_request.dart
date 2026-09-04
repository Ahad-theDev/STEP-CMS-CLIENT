class CalendarEntryCreateRequest {
  final DateTime? date;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String type; // holiday | event | half_day
  final String title;
  final bool attendanceRequired;

  CalendarEntryCreateRequest({
    this.date,
    this.dateFrom,
    this.dateTo,
    required this.type,
    required this.title,
    this.attendanceRequired = false,
  });

  static String _fmt(DateTime d) => d.toIso8601String().split('T').first;

  Map<String, dynamic> toJson() => {
        if (date != null) 'date': _fmt(date!),
        if (dateFrom != null) 'date_from': _fmt(dateFrom!),
        if (dateTo != null) 'date_to': _fmt(dateTo!),
        'type': type,
        'title': title,
        'attendance_required': attendanceRequired,
      };
}