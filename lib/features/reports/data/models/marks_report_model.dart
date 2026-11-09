import 'package:flutter/foundation.dart';
import 'package:cms/core/utils/numeric_utils.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/exams/data/models/exam_marks_grid_model.dart';
import 'package:cms/features/exams/data/models/exam_results_model.dart';
import 'daily_attendance_report_model.dart';

@immutable
class MarksReportExamMeta {
  final String examId;
  final String title;
  final String examType;
  final String academicYear;
  final String? termName;
  final String? examDate;
  final String? publishedAt;

  const MarksReportExamMeta({
    required this.examId,
    required this.title,
    required this.examType,
    required this.academicYear,
    this.termName,
    this.examDate,
    this.publishedAt,
  });

  factory MarksReportExamMeta.fromJson(Map<String, dynamic> json) {
    return MarksReportExamMeta(
      examId: json['exam_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      examType: json['exam_type']?.toString() ?? '',
      academicYear: json['academic_year']?.toString() ?? '',
      termName: json['term_name']?.toString(),
      examDate: json['exam_date']?.toString(),
      publishedAt: json['published_at']?.toString(),
    );
  }
}

@immutable
class MarksReportSummary {
  final int studentsCount;
  final double totalObtainedMarks;
  final double totalMaximumMarks;
  final double averagePercentage;
  final double maximumMarksPerStudent;

  const MarksReportSummary({
    this.studentsCount = 0,
    this.totalObtainedMarks = 0.0,
    this.totalMaximumMarks = 0.0,
    this.averagePercentage = 0.0,
    this.maximumMarksPerStudent = 0.0,
  });

  factory MarksReportSummary.fromJson(Map<String, dynamic> json) {
    return MarksReportSummary(
      studentsCount: parseInt(json['students_count']),
      totalObtainedMarks: parseDouble(json['total_obtained_marks']),
      totalMaximumMarks: parseDouble(json['total_maximum_marks']),
      averagePercentage: parseDouble(json['average_percentage']),
      maximumMarksPerStudent: parseDouble(json['maximum_marks_per_student']),
    );
  }
}

@immutable
class MarksReportSubjectSummary {
  final String examSubjectId;
  final String subjectName;
  final double maxMarksPerStudent;
  final double classMaximumMarks;
  final double classObtainedMarks;
  final int studentsMarked;

  const MarksReportSubjectSummary({
    required this.examSubjectId,
    required this.subjectName,
    this.maxMarksPerStudent = 0.0,
    this.classMaximumMarks = 0.0,
    this.classObtainedMarks = 0.0,
    this.studentsMarked = 0,
  });

  factory MarksReportSubjectSummary.fromJson(Map<String, dynamic> json) {
    return MarksReportSubjectSummary(
      examSubjectId: json['exam_subject_id']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      maxMarksPerStudent: parseDouble(json['max_marks_per_student']),
      classMaximumMarks: parseDouble(json['class_maximum_marks']),
      classObtainedMarks: parseDouble(json['class_obtained_marks']),
      studentsMarked: parseInt(json['students_marked']),
    );
  }
}

@immutable
class MarksSubjectResultItem {
  final String examSubjectId;
  final String subjectName;
  final double maxMarks;
  final double passingMarks;
  final double? marksObtained;
  final bool isAbsent;
  final bool? isPassed;
  final String? remarks;

  const MarksSubjectResultItem({
    required this.examSubjectId,
    required this.subjectName,
    required this.maxMarks,
    required this.passingMarks,
    this.marksObtained,
    this.isAbsent = false,
    this.isPassed,
    this.remarks,
  });

  factory MarksSubjectResultItem.fromJson(Map<String, dynamic> json) {
    return MarksSubjectResultItem(
      examSubjectId: json['exam_subject_id']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      maxMarks: parseDouble(json['max_marks']),
      passingMarks: parseDouble(json['passing_marks']),
      marksObtained: parseNullableDouble(json['marks_obtained']),
      isAbsent: json['is_absent'] == true,
      isPassed: json['is_passed'] as bool?,
      remarks: json['remarks']?.toString(),
    );
  }
}

@immutable
class MarksReportStudent {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final double totalObtained;
  final double totalMaximum;
  final double percentage;
  final List<MarksSubjectResultItem> subjectResults;

  const MarksReportStudent({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    this.totalObtained = 0.0,
    this.totalMaximum = 0.0,
    this.percentage = 0.0,
    this.subjectResults = const [],
  });

  factory MarksReportStudent.fromJson(Map<String, dynamic> json) {
    final rawResults = json['subject_results'] as List<dynamic>? ?? [];
    return MarksReportStudent(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      totalObtained: parseDouble(json['total_obtained']),
      totalMaximum: parseDouble(json['total_maximum']),
      percentage: parseDouble(json['percentage']),
      subjectResults: rawResults
          .map((r) => MarksSubjectResultItem.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  StudentExamResult toStudentExamResult({
    required String examId,
    required String examTitle,
  }) {
    return StudentExamResult(
      studentId: studentId,
      studentName: studentName,
      rollNumber: rollNumber,
      examId: examId,
      examTitle: examTitle,
      examStatus: ExamStatus.published,
      subjectResults: subjectResults
          .map((s) => GridMark(
                examSubjectId: s.examSubjectId,
                subjectName: s.subjectName,
                maxMarks: s.maxMarks,
                passingMarks: s.passingMarks,
                marksObtained: s.marksObtained,
                isAbsent: s.isAbsent,
                remarks: s.remarks,
              ))
          .toList(),
      totalObtained: totalObtained,
      totalMaximum: totalMaximum,
      percentage: percentage,
    );
  }
}

@immutable
class MarksReport {
  final ReportMeta meta;
  final MarksReportExamMeta exam;
  final MarksReportSummary summary;
  final List<MarksReportSubjectSummary> subjects;
  final List<MarksReportStudent> students;

  const MarksReport({
    required this.meta,
    required this.exam,
    required this.summary,
    required this.subjects,
    required this.students,
  });

  factory MarksReport.fromJson(Map<String, dynamic> json) {
    final rawSubjects = json['subjects'] as List<dynamic>? ?? [];
    final rawStudents = json['students'] as List<dynamic>? ?? [];

    return MarksReport(
      meta: ReportMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
      exam: MarksReportExamMeta.fromJson(
        (json['exam'] as Map<String, dynamic>?) ?? {},
      ),
      summary: MarksReportSummary.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? {},
      ),
      subjects: rawSubjects
          .map((s) => MarksReportSubjectSummary.fromJson(s as Map<String, dynamic>))
          .toList(),
      students: rawStudents
          .map((st) => MarksReportStudent.fromJson(st as Map<String, dynamic>))
          .toList(),
    );
  }
}
