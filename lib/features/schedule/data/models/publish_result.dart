class PublishResult {
  final String date;
  final bool isHoliday;
  final List<String> notified;
  final List<String> skippedDuplicate;

  PublishResult({
    required this.date,
    required this.isHoliday,
    required this.notified,
    required this.skippedDuplicate,
  });

  factory PublishResult.fromJson(Map<String, dynamic> json) => PublishResult(
        date: json['date'] as String,
        isHoliday: json['is_holiday'] as bool,
        notified: List<String>.from(json['notified'] as List),
        skippedDuplicate: List<String>.from(json['skipped_duplicate'] as List),
      );
}