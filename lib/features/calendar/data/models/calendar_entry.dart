class CalendarEntry {
  final String id;
  final String date;
  final String type;

  CalendarEntry({required this.id, required this.date, required this.type});

  factory CalendarEntry.fromJson(Map<String, dynamic> json) => CalendarEntry(
        id: json['id'] as String,
        date: json['date'] as String,
        type: json['type'] as String,
      );
}