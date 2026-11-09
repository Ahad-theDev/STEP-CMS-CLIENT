import 'package:flutter/foundation.dart';
import 'package:cms/core/utils/numeric_utils.dart';
import 'exam_model.dart';
import 'exam_subject_model.dart';

@immutable
class GridMark {
  final String examSubjectId;
  final String subjectName;
  final double maxMarks;
  final double passingMarks;
  final double? marksObtained;
  final bool isAbsent;
  final String? remarks;

  const GridMark({
    required this.examSubjectId,
    required this.subjectName,
    required this.maxMarks,
    required this.passingMarks,
    this.marksObtained,
    this.isAbsent = false,
    this.remarks,
  });

  bool get isEntered => marksObtained != null || isAbsent;

  GridMark copyWith({
    String? examSubjectId,
    String? subjectName,
    double? maxMarks,
    double? passingMarks,
    double? marksObtained,
    bool clearMarks = false,
    bool? isAbsent,
    String? remarks,
  }) {
    return GridMark(
      examSubjectId: examSubjectId ?? this.examSubjectId,
      subjectName: subjectName ?? this.subjectName,
      maxMarks: maxMarks ?? this.maxMarks,
      passingMarks: passingMarks ?? this.passingMarks,
      marksObtained: clearMarks ? null : (marksObtained ?? this.marksObtained),
      isAbsent: isAbsent ?? this.isAbsent,
      remarks: remarks ?? this.remarks,
    );
  }

  factory GridMark.fromJson(Map<String, dynamic> json) {
    return GridMark(
      examSubjectId: json['exam_subject_id']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      maxMarks: parseDouble(json['max_marks'], 100.0),
      passingMarks: parseDouble(json['passing_marks'], 33.0),
      marksObtained: parseNullableDouble(json['marks_obtained']),
      isAbsent: json['is_absent'] == true,
      remarks: json['remarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'exam_subject_id': examSubjectId,
    'subject_name': subjectName,
    'max_marks': maxMarks,
    'passing_marks': passingMarks,
    'marks_obtained': marksObtained,
    'is_absent': isAbsent,
    'remarks': remarks,
  };
}

@immutable
class GridStudent {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final List<GridMark> marks;

  const GridStudent({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.marks,
  });

  factory GridStudent.fromJson(Map<String, dynamic> json) {
    final rawMarks = json['marks'] as List<dynamic>? ?? [];
    return GridStudent(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      marks: rawMarks
          .map((m) => GridMark.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'student_name': studentName,
    'roll_number': rollNumber,
    'marks': marks.map((m) => m.toJson()).toList(),
  };
}

@immutable
class ExamMarksGrid {
  final String examId;
  final String examTitle;
  final String classId;
  final ExamStatus examStatus;
  final String academicYear;
  final List<ExamSubject> subjects;
  final List<GridStudent> students;

  const ExamMarksGrid({
    required this.examId,
    required this.examTitle,
    required this.classId,
    required this.examStatus,
    required this.academicYear,
    required this.subjects,
    required this.students,
  });

  bool get isPublished => examStatus == ExamStatus.published;

  factory ExamMarksGrid.fromJson(Map<String, dynamic> json) {
    final rawSubjects = json['subjects'] as List<dynamic>? ?? [];
    final rawStudents = json['students'] as List<dynamic>? ?? [];

    return ExamMarksGrid(
      examId: json['exam_id']?.toString() ?? '',
      examTitle: json['exam_title']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      examStatus: ExamStatus.fromString(json['exam_status']?.toString() ?? ''),
      academicYear: json['academic_year']?.toString() ?? '',
      subjects: rawSubjects
          .map((s) => ExamSubject.fromJson(s as Map<String, dynamic>))
          .toList(),
      students: rawStudents
          .map((st) => GridStudent.fromJson(st as Map<String, dynamic>))
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
