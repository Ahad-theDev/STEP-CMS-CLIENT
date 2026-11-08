class DailyAttendanceMarkResult {
  final String message;
  final int created;
  final int updated;

  const DailyAttendanceMarkResult({
    required this.message,
    required this.created,
    required this.updated,
  });

  factory DailyAttendanceMarkResult.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceMarkResult(
      message: json['message'] as String? ?? 'Attendance saved',
      created: (json['created'] as num?)?.toInt() ?? 0,
      updated: (json['updated'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'created': created,
      'updated': updated,
    };
  }
}
