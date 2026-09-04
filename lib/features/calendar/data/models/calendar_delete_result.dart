class CalendarDeleteResult {
  final int deletedCount;
  final String dateFrom;
  final String dateTo;

  CalendarDeleteResult({required this.deletedCount, required this.dateFrom, required this.dateTo});

  factory CalendarDeleteResult.fromJson(Map<String, dynamic> json) => CalendarDeleteResult(
        deletedCount: json['deleted_count'] as int,
        dateFrom: json['date_from'] as String,
        dateTo: json['date_to'] as String,
      );
}