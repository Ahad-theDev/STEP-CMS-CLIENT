class StudentAttendanceRecord {
  final String id;
  final String lectureId;
  final String studentId;
  final String studentName;
  final String date;
  final String status;
  final String? remarks;
  final String markedBy;
  final String markedAt;

  StudentAttendanceRecord({
    required this.id,
    required this.lectureId,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.status,
    this.remarks,
    required this.markedBy,
    required this.markedAt,
  });

  factory StudentAttendanceRecord.fromJson(Map<String, dynamic> json) => StudentAttendanceRecord(
        id: json['id'] as String,
        lectureId: json['lecture_id'] as String,
        studentId: json['student_id'] as String,
        studentName: json['student_name'] as String,
        date: json['date'] as String,
        status: json['status'] as String,
        remarks: json['remarks'] as String?,
        markedBy: json['marked_by'] as String,
        markedAt: json['marked_at'] as String,
      );
}