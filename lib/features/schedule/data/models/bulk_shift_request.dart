class BulkShiftRequest {
  final DateTime date;
  final int shiftMinutes;
  final String reason;

  BulkShiftRequest({required this.date, required this.shiftMinutes, required this.reason});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T').first,
        'shift_minutes': shiftMinutes,
        'reason': reason,
      };
}