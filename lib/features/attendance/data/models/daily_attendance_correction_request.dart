class DailyAttendanceCorrectionRequest {
  final String attendanceDate; // 'YYYY-MM-DD'
  final String? morningStatus; // 'present' | 'absent' | 'late' | 'leave'
  final String? closingStatus; // 'present' | 'absent'
  final String? remarks;
  final String reason;

  const DailyAttendanceCorrectionRequest({
    required this.attendanceDate,
    this.morningStatus,
    this.closingStatus,
    this.remarks,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'attendance_date': attendanceDate,
      'reason': reason.trim(),
    };
    if (morningStatus != null) {
      map['morning_status'] = morningStatus;
    }
    if (closingStatus != null) {
      map['closing_status'] = closingStatus;
    }
    if (remarks != null) {
      map['remarks'] = remarks!.trim();
    }
    return map;
  }
}
