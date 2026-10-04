class AttendanceMarkAllExceptionRequest {
  final String studentId;
  final String status;
  final String? remarks;

  AttendanceMarkAllExceptionRequest({
    required this.studentId,
    required this.status,
    this.remarks,
  });

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'status': status,
        if (remarks != null) 'remarks': remarks,
      };
}

class AttendanceMarkAllRequest {
  final String lectureId;
  final DateTime date;
  final String defaultStatus;
  final List<AttendanceMarkAllExceptionRequest> exceptions;

  AttendanceMarkAllRequest({
    required this.lectureId,
    required this.date,
    this.defaultStatus = 'present',
    this.exceptions = const [],
  });

  Map<String, dynamic> toJson() => {
        'lecture_id': lectureId,
        'date': date.toIso8601String().split('T').first,
        'default_status': defaultStatus,
        'exceptions': exceptions.map((e) => e.toJson()).toList(),
      };
}
