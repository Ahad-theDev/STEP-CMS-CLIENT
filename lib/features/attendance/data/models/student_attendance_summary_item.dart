class StudentAttendanceSummaryItem {
  final String studentId;
  final String studentName;
  final int totalLectures;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int leaveCount;
  final double percentagePresent;

  StudentAttendanceSummaryItem({
    required this.studentId,
    required this.studentName,
    required this.totalLectures,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.leaveCount,
    required this.percentagePresent,
  });

  factory StudentAttendanceSummaryItem.fromJson(Map<String, dynamic> json) =>
      StudentAttendanceSummaryItem(
        studentId: json['student_id'] as String,
        studentName: json['student_name'] as String,
        totalLectures: json['total_lectures'] as int,
        presentCount: json['present_count'] as int,
        absentCount: json['absent_count'] as int,
        lateCount: json['late_count'] as int,
        leaveCount: json['leave_count'] as int,
        percentagePresent: (json['percentage_present'] as num).toDouble(),
      );
}