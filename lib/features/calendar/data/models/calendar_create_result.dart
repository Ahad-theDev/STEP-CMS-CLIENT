class CalendarSkipped {
  final String date;
  final String reason;

  CalendarSkipped({required this.date, required this.reason});

  factory CalendarSkipped.fromJson(Map<String, dynamic> json) => CalendarSkipped(
        date: json['date'] as String,
        reason: json['reason'] as String,
      );
}

class CalendarCreateResult {
  final List<String> created;
  final List<CalendarSkipped> skipped;

  CalendarCreateResult({required this.created, required this.skipped});

  factory CalendarCreateResult.fromJson(Map<String, dynamic> json) => CalendarCreateResult(
        created: List<String>.from(json['created'] as List),
        skipped: (json['skipped'] as List)
            .map((e) => CalendarSkipped.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}