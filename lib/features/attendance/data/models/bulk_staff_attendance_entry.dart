class BulkStaffAttendanceEntry {
  final String? staffId;
  final String? teacherId;
  final String status;

  BulkStaffAttendanceEntry({this.staffId, this.teacherId, required this.status});

  Map<String, dynamic> toJson() => {
        if (staffId != null) 'staff_id': staffId,
        if (teacherId != null) 'teacher_id': teacherId,
        'status': status,
      };
}