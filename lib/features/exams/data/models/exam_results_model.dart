import 'package:flutter/foundation.dart';
import 'package:cms/core/utils/numeric_utils.dart';
import 'exam_model.dart';
import 'exam_subject_model.dart';
import 'exam_marks_grid_model.dart';

@immutable
class ExamClassResultStudent {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final List<GridMark> subjectResults;
  final double totalObtained;
  final double totalMaximum;
  final double percentage;

  const ExamClassResultStudent({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.subjectResults,
    required this.totalObtained,
    required this.totalMaximum,
    required this.percentage,
  });

  factory ExamClassResultStudent.fromJson(Map<String, dynamic> json) {
    final rawResults = json['subject_results'] as List<dynamic>? ?? [];
    return ExamClassResultStudent(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      subjectResults: rawResults
          .map((r) => GridMark.fromJson(r as Map<String, dynamic>))
          .toList(),
      totalObtained: parseDouble(json['total_obtained']),
      totalMaximum: parseDouble(json['total_maximum']),
      percentage: parseDouble(json['percentage']),
    );
  }

  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'student_name': studentName,
    'roll_number': rollNumber,
    'subject_results': subjectResults.map((r) => r.toJson()).toList(),
    'total_obtained': totalObtained,
    'total_maximum': totalMaximum,
    'percentage': percentage,
  };

  StudentExamResult toStudentExamResult({
    required String examId,
    required String examTitle,
    required ExamStatus examStatus,
  }) {
    return StudentExamResult(
      studentId: studentId,
      studentName: studentName,
      rollNumber: rollNumber,
      examId: examId,
      examTitle: examTitle,
      examStatus: examStatus,
      subjectResults: subjectResults,
      totalObtained: totalObtained,
      totalMaximum: totalMaximum,
      percentage: percentage,
    );
  }
}

@immutable
class ExamClassResults {
  final String examId;
  final String examTitle;
  final String classId;
  final ExamStatus examStatus;
  final String academicYear;
  final List<ExamSubject> subjects;
  final List<ExamClassResultStudent> students;

  const ExamClassResults({
    required this.examId,
    required this.examTitle,
    required this.classId,
    required this.examStatus,
    required this.academicYear,
    required this.subjects,
    required this.students,
  });

  factory ExamClassResults.fromJson(Map<String, dynamic> json) {
    final rawSubjects = json['subjects'] as List<dynamic>? ?? [];
    final rawStudents = json['students'] as List<dynamic>? ?? [];

    return ExamClassResults(
      examId: json['exam_id']?.toString() ?? '',
      examTitle: json['exam_title']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      examStatus: ExamStatus.fromString(json['exam_status']?.toString() ?? ''),
      academicYear: json['academic_year']?.toString() ?? '',
      subjects: rawSubjects
          .map((s) => ExamSubject.fromJson(s as Map<String, dynamic>))
          .toList(),
      students: rawStudents
          .map((st) => ExamClassResultStudent.fromJson(st as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'exam_id': examId,
    'exam_title': examTitle,
    'class_id': classId,
    'exam_status': examStatus.value,
    'academic_year': academicYear,
    'subjects': subjects.map((s) => s.toJson()).toList(),
    'students': students.map((st) => st.toJson()).toList(),
  };
}

@immutable
class StudentExamResult {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String examId;
  final String examTitle;
  final ExamStatus examStatus;
  final List<GridMark> subjectResults;
  final double totalObtained;
  final double totalMaximum;
  final double percentage;

  const StudentExamResult({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.examId,
    required this.examTitle,
    required this.examStatus,
    required this.subjectResults,
    required this.totalObtained,
    required this.totalMaximum,
    required this.percentage,
  });

  factory StudentExamResult.fromJson(Map<String, dynamic> json) {
    final rawResults = json['subject_results'] as List<dynamic>? ?? [];
    return StudentExamResult(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      examId: json['exam_id']?.toString() ?? '',
      examTitle: json['exam_title']?.toString() ?? '',
      examStatus: ExamStatus.fromString(json['exam_status']?.toString() ?? ''),
      subjectResults: rawResults
          .map((r) => GridMark.fromJson(r as Map<String, dynamic>))
          .toList(),
      totalObtained: parseDouble(json['total_obtained']),
      totalMaximum: parseDouble(json['total_maximum']),
      percentage: parseDouble(json['percentage']),
    );
  }

  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'student_name': studentName,
    'roll_number': rollNumber,
    'exam_id': examId,
    'exam_title': examTitle,
    'exam_status': examStatus.value,
    'subject_results': subjectResults.map((r) => r.toJson()).toList(),
    'total_obtained': totalObtained,
    'total_maximum': totalMaximum,
    'percentage': percentage,
  };
}

@immutable
class StudentExamHistoryResponse {
  final List<StudentExamResult> items;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const StudentExamHistoryResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory StudentExamHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return StudentExamHistoryResponse(
      items: rawItems
          .map((i) => StudentExamResult.fromJson(i as Map<String, dynamic>))
          .toList(),
      page: parseInt(json['page'], 1),
      limit: parseInt(json['limit'], 20),
      total: parseInt(json['total'], 0),
      pages: parseInt(json['pages'], 0),
    );
  }
}
