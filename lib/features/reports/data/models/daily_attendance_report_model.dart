import 'package:flutter/foundation.dart';
import 'package:cms/core/utils/numeric_utils.dart';

@immutable
class ReportMeta {
  final String reportType;
  final String scope;
  final String generatedAt;
  final Map<String, dynamic> filters;

  const ReportMeta({
    required this.reportType,
    required this.scope,
    required this.generatedAt,
    required this.filters,
  });

  factory ReportMeta.fromJson(Map<String, dynamic> json) {
    return ReportMeta(
      reportType: json['report_type']?.toString() ?? '',
      scope: json['scope']?.toString() ?? '',
      generatedAt: json['generated_at']?.toString() ?? '',
      filters: json['filters'] is Map
          ? Map<String, dynamic>.from(json['filters'] as Map)
          : const {},
    );
  }
}

@immutable
class DailyAttendanceSummary {
  final int daysRecorded;
  final int present;
  final int late;
  final int absent;
  final int leave;
  final int shortLeave;
  final int unfinalized;
  final double attendancePercentage;
  final int uniqueAttendanceDates;

  const DailyAttendanceSummary({
    this.daysRecorded = 0,
    this.present = 0,
    this.late = 0,
    this.absent = 0,
    this.leave = 0,
    this.shortLeave = 0,
    this.unfinalized = 0,
    this.attendancePercentage = 0.0,
    this.uniqueAttendanceDates = 0,
  });

  factory DailyAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceSummary(
      daysRecorded: parseInt(json['days_recorded']),
      present: parseInt(json['present']),
      late: parseInt(json['late']),
      absent: parseInt(json['absent']),
      leave: parseInt(json['leave']),
      shortLeave: parseInt(json['short_leave']),
      unfinalized: parseInt(json['unfinalized']),
      attendancePercentage: parseDouble(json['attendance_percentage']),
      uniqueAttendanceDates: parseInt(json['unique_attendance_dates']),
    );
  }
}

@immutable
class DailyAttendanceStudentRow {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final int daysRecorded;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final int leaveDays;
  final int shortLeaveDays;
  final int unfinalizedDays;
  final double attendancePercentage;

  const DailyAttendanceStudentRow({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    this.daysRecorded = 0,
    this.presentDays = 0,
    this.lateDays = 0,
    this.absentDays = 0,
    this.leaveDays = 0,
    this.shortLeaveDays = 0,
    this.unfinalizedDays = 0,
    this.attendancePercentage = 0.0,
  });

  factory DailyAttendanceStudentRow.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceStudentRow(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      daysRecorded: parseInt(json['days_recorded']),
      presentDays: parseInt(json['present_days']),
      lateDays: parseInt(json['late_days']),
      absentDays: parseInt(json['absent_days']),
      leaveDays: parseInt(json['leave_days']),
      shortLeaveDays: parseInt(json['short_leave_days']),
      unfinalizedDays: parseInt(json['unfinalized_days']),
      attendancePercentage: parseDouble(json['attendance_percentage']),
    );
  }
}

@immutable
class DailyAttendanceRecordRow {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String classId;
  final String attendanceDate;
  final String? morningStatus;
  final String? closingStatus;
  final String? finalStatus;
  final String? remarks;

  const DailyAttendanceRecordRow({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.classId,
    required this.attendanceDate,
    this.morningStatus,
    this.closingStatus,
    this.finalStatus,
    this.remarks,
  });

  factory DailyAttendanceRecordRow.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceRecordRow(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      attendanceDate: json['attendance_date']?.toString() ?? '',
      morningStatus: json['morning_status']?.toString(),
      closingStatus: json['closing_status']?.toString(),
      finalStatus: json['final_status']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }
}

@immutable
class DailyAttendanceReport {
  final ReportMeta meta;
  final DailyAttendanceSummary summary;
  final List<DailyAttendanceStudentRow> students;
  final List<DailyAttendanceRecordRow> records;

  const DailyAttendanceReport({
    required this.meta,
    required this.summary,
    required this.students,
    required this.records,
  });

  factory DailyAttendanceReport.fromJson(Map<String, dynamic> json) {
    final rawStudents = json['students'] as List<dynamic>? ?? [];
    final rawRecords = json['records'] as List<dynamic>? ?? [];

    return DailyAttendanceReport(
      meta: ReportMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
      summary: DailyAttendanceSummary.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? {},
      ),
      students: rawStudents
          .map((s) => DailyAttendanceStudentRow.fromJson(s as Map<String, dynamic>))
          .toList(),
      records: rawRecords
          .map((r) => DailyAttendanceRecordRow.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
