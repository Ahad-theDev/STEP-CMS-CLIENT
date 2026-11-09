import 'package:flutter/foundation.dart';
import 'package:cms/core/utils/numeric_utils.dart';
import 'daily_attendance_report_model.dart';

@immutable
class FeeReportSummary {
  final double totalFeeDue;
  final double totalFeeSubmitted;
  final double outstandingFee;
  final int feeRecords;
  final int paidRecords;
  final int partialRecords;
  final int unpaidRecords;
  final int studentsWithFeeRecords;
  final int studentsInReport;
  final double collectionPercentage;

  const FeeReportSummary({
    this.totalFeeDue = 0.0,
    this.totalFeeSubmitted = 0.0,
    this.outstandingFee = 0.0,
    this.feeRecords = 0,
    this.paidRecords = 0,
    this.partialRecords = 0,
    this.unpaidRecords = 0,
    this.studentsWithFeeRecords = 0,
    this.studentsInReport = 0,
    this.collectionPercentage = 0.0,
  });

  factory FeeReportSummary.fromJson(Map<String, dynamic> json) {
    return FeeReportSummary(
      totalFeeDue: parseDouble(json['total_fee_due']),
      totalFeeSubmitted: parseDouble(json['total_fee_submitted']),
      outstandingFee: parseDouble(json['outstanding_fee']),
      feeRecords: parseInt(json['fee_records']),
      paidRecords: parseInt(json['paid_records']),
      partialRecords: parseInt(json['partial_records']),
      unpaidRecords: parseInt(json['unpaid_records']),
      studentsWithFeeRecords: parseInt(json['students_with_fee_records']),
      studentsInReport: parseInt(json['students_in_report']),
      collectionPercentage: parseDouble(json['collection_percentage']),
    );
  }
}

@immutable
class FeeReportRecordItem {
  final String feeRecordId;
  final String classId;
  final int month;
  final int year;
  final double amountDue;
  final double amountPaid;
  final double outstanding;
  final String status;
  final String? paymentDate;

  const FeeReportRecordItem({
    required this.feeRecordId,
    required this.classId,
    required this.month,
    required this.year,
    required this.amountDue,
    required this.amountPaid,
    required this.outstanding,
    required this.status,
    this.paymentDate,
  });

  factory FeeReportRecordItem.fromJson(Map<String, dynamic> json) {
    return FeeReportRecordItem(
      feeRecordId: json['fee_record_id']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      month: parseInt(json['month'], 1),
      year: parseInt(json['year'], 2026),
      amountDue: parseDouble(json['amount_due']),
      amountPaid: parseDouble(json['amount_paid']),
      outstanding: parseDouble(json['outstanding']),
      status: json['status']?.toString() ?? 'unpaid',
      paymentDate: json['payment_date']?.toString(),
    );
  }
}

@immutable
class FeeReportStudent {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String? classId;
  final double totalFeeDue;
  final double totalFeeSubmitted;
  final double outstandingFee;
  final int paidRecords;
  final int partialRecords;
  final int unpaidRecords;
  final List<FeeReportRecordItem> feeRecords;

  const FeeReportStudent({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    this.classId,
    this.totalFeeDue = 0.0,
    this.totalFeeSubmitted = 0.0,
    this.outstandingFee = 0.0,
    this.paidRecords = 0,
    this.partialRecords = 0,
    this.unpaidRecords = 0,
    this.feeRecords = const [],
  });

  factory FeeReportStudent.fromJson(Map<String, dynamic> json) {
    final rawRecords = json['fee_records'] as List<dynamic>? ?? [];
    return FeeReportStudent(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      classId: json['class_id']?.toString(),
      totalFeeDue: parseDouble(json['total_fee_due']),
      totalFeeSubmitted: parseDouble(json['total_fee_submitted']),
      outstandingFee: parseDouble(json['outstanding_fee']),
      paidRecords: parseInt(json['paid_records']),
      partialRecords: parseInt(json['partial_records']),
      unpaidRecords: parseInt(json['unpaid_records']),
      feeRecords: rawRecords
          .map((r) => FeeReportRecordItem.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  String get paymentStatus {
    if (outstandingFee <= 0 && paidRecords > 0) return 'paid';
    if (paidRecords > 0 && outstandingFee > 0) return 'partial';
    if (unpaidRecords > 0) return 'unpaid';
    return 'pending';
  }
}

@immutable
class FeeReport {
  final ReportMeta meta;
  final FeeReportSummary summary;
  final List<FeeReportStudent> students;

  const FeeReport({
    required this.meta,
    required this.summary,
    required this.students,
  });

  factory FeeReport.fromJson(Map<String, dynamic> json) {
    final rawStudents = json['students'] as List<dynamic>? ?? [];
    return FeeReport(
      meta: ReportMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
      summary: FeeReportSummary.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? {},
      ),
      students: rawStudents
          .map((s) => FeeReportStudent.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
