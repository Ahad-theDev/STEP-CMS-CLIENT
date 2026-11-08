class ClosingAttendanceEntry {
  final String studentId;
  final String status; // 'present' | 'absent'
  final String? remarks;

  const ClosingAttendanceEntry({
    required this.studentId,
    required this.status,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'status': status,
      if (remarks != null && remarks!.trim().isNotEmpty)
        'remarks': remarks!.trim(),
    };
  }

  factory ClosingAttendanceEntry.fromJson(Map<String, dynamic> json) {
    return ClosingAttendanceEntry(
      studentId: json['student_id'] as String,
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
    );
  }
}

class ClosingAttendanceRequest {
  final String attendanceDate; // 'YYYY-MM-DD'
  final List<ClosingAttendanceEntry> entries;

  const ClosingAttendanceRequest({
    required this.attendanceDate,
    required this.entries,
  });

  Map<String, dynamic> toJson() {
    return {
      'attendance_date': attendanceDate,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  factory ClosingAttendanceRequest.fromJson(Map<String, dynamic> json) {
    return ClosingAttendanceRequest(
      attendanceDate: json['attendance_date'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => ClosingAttendanceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
