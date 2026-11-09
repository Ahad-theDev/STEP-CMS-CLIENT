import 'package:flutter/foundation.dart';
import 'package:cms/core/utils/numeric_utils.dart';
import 'daily_attendance_report_model.dart';

@immutable
class LectureAttendanceSummary {
  final int present;
  final int late;
  final int absent;
  final int leave;
  final int attendanceEntries;
  final int attendedLectures;
  final double attendancePercentage;
  final int scheduledLectureSlots;

  const LectureAttendanceSummary({
    this.present = 0,
    this.late = 0,
    this.absent = 0,
    this.leave = 0,
    this.attendanceEntries = 0,
    this.attendedLectures = 0,
    this.attendancePercentage = 0.0,
    this.scheduledLectureSlots = 0,
  });

  factory LectureAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return LectureAttendanceSummary(
      present: parseInt(json['present']),
      late: parseInt(json['late']),
      absent: parseInt(json['absent']),
      leave: parseInt(json['leave']),
      attendanceEntries: parseInt(json['attendance_entries']),
      attendedLectures: parseInt(json['attended_lectures']),
      attendancePercentage: parseDouble(json['attendance_percentage']),
      scheduledLectureSlots: parseInt(json['scheduled_lecture_slots']),
    );
  }
}

@immutable
class LectureAttendanceStudentRow {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final int leaveCount;
  final int markedLectures;
  final int attendedLectures;
  final int totalLectures;
  final double attendancePercentage;

  const LectureAttendanceStudentRow({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    this.presentCount = 0,
    this.lateCount = 0,
    this.absentCount = 0,
    this.leaveCount = 0,
    this.markedLectures = 0,
    this.attendedLectures = 0,
    this.totalLectures = 0,
    this.attendancePercentage = 0.0,
  });

  factory LectureAttendanceStudentRow.fromJson(Map<String, dynamic> json) {
    return LectureAttendanceStudentRow(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      presentCount: parseInt(json['present_count']),
      lateCount: parseInt(json['late_count']),
      absentCount: parseInt(json['absent_count']),
      leaveCount: parseInt(json['leave_count']),
      markedLectures: parseInt(json['marked_lectures']),
      attendedLectures: parseInt(json['attended_lectures']),
      totalLectures: parseInt(json['total_lectures']),
      attendancePercentage: parseDouble(json['attendance_percentage']),
    );
  }
}

@immutable
class LectureAttendanceRecordRow {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String? lectureId;
  final String? date;
  final String? status;
  final String? remarks;
  final String? checkInTime;

  const LectureAttendanceRecordRow({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    this.lectureId,
    this.date,
    this.status,
    this.remarks,
    this.checkInTime,
  });

  factory LectureAttendanceRecordRow.fromJson(Map<String, dynamic> json) {
    return LectureAttendanceRecordRow(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      lectureId: json['lecture_id']?.toString(),
      date: json['date']?.toString(),
      status: json['status']?.toString(),
      remarks: json['remarks']?.toString(),
      checkInTime: json['check_in_time']?.toString(),
    );
  }
}

@immutable
class LectureAttendanceReport {
  final ReportMeta meta;
  final LectureAttendanceSummary summary;
  final List<LectureAttendanceStudentRow> students;
  final List<LectureAttendanceRecordRow> records;

  const LectureAttendanceReport({
    required this.meta,
    required this.summary,
    required this.students,
    required this.records,
  });

  factory LectureAttendanceReport.fromJson(Map<String, dynamic> json) {
    final rawStudents = json['students'] as List<dynamic>? ?? [];
    final rawRecords = json['records'] as List<dynamic>? ?? [];

    return LectureAttendanceReport(
      meta: ReportMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
      summary: LectureAttendanceSummary.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? {},
      ),
      students: rawStudents
          .map((s) => LectureAttendanceStudentRow.fromJson(s as Map<String, dynamic>))
          .toList(),
      records: rawRecords
          .map((r) => LectureAttendanceRecordRow.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
