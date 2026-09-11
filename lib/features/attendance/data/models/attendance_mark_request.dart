class AttendanceMarkEntryRequest {
  final String studentId;
  final String status;

  AttendanceMarkEntryRequest({required this.studentId, required this.status});

  Map<String, dynamic> toJson() => {'student_id': studentId, 'status': status};
}

class AttendanceMarkRequest {
  final String lectureId;
  final DateTime date;
  final List<AttendanceMarkEntryRequest> attendance;

  AttendanceMarkRequest({required this.lectureId, required this.date, required this.attendance});

  Map<String, dynamic> toJson() => {
        'lecture_id': lectureId,
        'date': date.toIso8601String().split('T').first,
        'attendance': attendance.map((e) => e.toJson()).toList(),
      };
}