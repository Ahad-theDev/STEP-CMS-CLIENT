double _parseDecimalString(dynamic value) {
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}

class FeeDefaulterItem {
  final String studentId;
  final String studentName;
  final String? classId;
  final int month;
  final int year;
  final double amountDue;
  final double amountPaid;
  final double remaining;
  final String status;
  final String dueDate;
  final int daysOverdue;

  FeeDefaulterItem({
    required this.studentId,
    required this.studentName,
    this.classId,
    required this.month,
    required this.year,
    required this.amountDue,
    required this.amountPaid,
    required this.remaining,
    required this.status,
    required this.dueDate,
    required this.daysOverdue,
  });

  factory FeeDefaulterItem.fromJson(Map<String, dynamic> json) => FeeDefaulterItem(
        studentId: json['student_id'] as String,
        studentName: json['student_name'] as String,
        classId: json['class_id'] as String?,
        month: json['month'] as int,
        year: json['year'] as int,
        amountDue: _parseDecimalString(json['amount_due']),
        amountPaid: _parseDecimalString(json['amount_paid']),
        remaining: _parseDecimalString(json['remaining']),
        status: json['status'] as String,
        dueDate: json['due_date'] as String,
        daysOverdue: json['days_overdue'] as int,
      );
}

class FeeDefaultersResponse {
  final int count;
  final List<FeeDefaulterItem> defaulters;

  FeeDefaultersResponse({required this.count, required this.defaulters});

  factory FeeDefaultersResponse.fromJson(Map<String, dynamic> json) => FeeDefaultersResponse(
        count: json['count'] as int,
        defaulters: (json['defaulters'] as List)
            .map((e) => FeeDefaulterItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}