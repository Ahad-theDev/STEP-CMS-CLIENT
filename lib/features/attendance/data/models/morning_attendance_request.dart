class MorningAttendanceEntry {
  final String studentId;
  final String status; // 'present' | 'absent' | 'late' | 'leave'
  final String? remarks;

  const MorningAttendanceEntry({
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

  factory MorningAttendanceEntry.fromJson(Map<String, dynamic> json) {
    return MorningAttendanceEntry(
      studentId: json['student_id'] as String,
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
    );
  }
}

class MorningAttendanceRequest {
  final String attendanceDate; // 'YYYY-MM-DD'
  final List<MorningAttendanceEntry> entries;

  const MorningAttendanceRequest({
    required this.attendanceDate,
    required this.entries,
  });

  Map<String, dynamic> toJson() {
    return {
      'attendance_date': attendanceDate,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  factory MorningAttendanceRequest.fromJson(Map<String, dynamic> json) {
    return MorningAttendanceRequest(
      attendanceDate: json['attendance_date'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => MorningAttendanceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
