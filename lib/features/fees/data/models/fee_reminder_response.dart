double _parseDecimalString(dynamic value) {
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}

class FeeReminderItem {
  final String studentId;
  final String studentName;
  final int month;
  final int year;
  final double amountDue;
  final double remaining;
  final String dueDate;

  FeeReminderItem({
    required this.studentId,
    required this.studentName,
    required this.month,
    required this.year,
    required this.amountDue,
    required this.remaining,
    required this.dueDate,
  });

  factory FeeReminderItem.fromJson(Map<String, dynamic> json) => FeeReminderItem(
        studentId: json['student_id'] as String,
        studentName: json['student_name'] as String,
        month: json['month'] as int,
        year: json['year'] as int,
        amountDue: _parseDecimalString(json['amount_due']),
        remaining: _parseDecimalString(json['remaining']),
        dueDate: json['due_date'] as String,
      );
}

class FeeReminderResponse {
  final int count;
  final List<FeeReminderItem> records;

  FeeReminderResponse({required this.count, required this.records});

  factory FeeReminderResponse.fromJson(Map<String, dynamic> json) => FeeReminderResponse(
        count: json['count'] as int,
        records: (json['records'] as List)
            .map((e) => FeeReminderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}