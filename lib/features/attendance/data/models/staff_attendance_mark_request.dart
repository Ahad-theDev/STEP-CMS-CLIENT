class StaffAttendanceMarkRequest {
  final String? staffId;
  final String? teacherId;
  final DateTime date;
  final String status;

  StaffAttendanceMarkRequest({
    this.staffId,
    this.teacherId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        if (staffId != null) 'staff_id': staffId,
        if (teacherId != null) 'teacher_id': teacherId,
        'date': date.toIso8601String().split('T').first,
        'status': status,
      };
}