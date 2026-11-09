import 'package:flutter/foundation.dart';

@immutable
class StudentSubjectMarkEntry {
  final String examSubjectId;
  final double marksObtained;
  final bool isAbsent;
  final String? remarks;

  const StudentSubjectMarkEntry({
    required this.examSubjectId,
    required this.marksObtained,
    this.isAbsent = false,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'exam_subject_id': examSubjectId,
      'marks_obtained': isAbsent ? 0.0 : marksObtained,
      'is_absent': isAbsent,
    };
    if (remarks != null && remarks!.trim().isNotEmpty) {
      map['remarks'] = remarks!.trim();
    }
    return map;
  }
}

@immutable
class StudentMarksEntry {
  final String studentId;
  final List<StudentSubjectMarkEntry> marks;

  const StudentMarksEntry({
    required this.studentId,
    required this.marks,
  });

  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'marks': marks.map((m) => m.toJson()).toList(),
  };
}

@immutable
class BulkExamMarksRequest {
  final List<StudentMarksEntry> entries;
  final String? correctionReason;

  const BulkExamMarksRequest({
    required this.entries,
    this.correctionReason,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'entries': entries.map((e) => e.toJson()).toList(),
    };
    if (correctionReason != null && correctionReason!.trim().isNotEmpty) {
      map['correction_reason'] = correctionReason!.trim();
    }
    return map;
  }
}

@immutable
class BulkExamMarksResponse {
  final String examId;
  final String status;
  final String message;
  final int studentsProcessed;
  final int subjectsProcessed;
  final int resultsCreated;
  final int resultsUpdated;
  final String? publishedAt;

  const BulkExamMarksResponse({
    required this.examId,
    required this.status,
    required this.message,
    this.studentsProcessed = 0,
    this.subjectsProcessed = 0,
    this.resultsCreated = 0,
    this.resultsUpdated = 0,
    this.publishedAt,
  });

  factory BulkExamMarksResponse.fromJson(Map<String, dynamic> json) {
    return BulkExamMarksResponse(
      examId: json['exam_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      studentsProcessed: (json['students_processed'] as num?)?.toInt() ?? 0,
      subjectsProcessed: (json['subjects_processed'] as num?)?.toInt() ?? 0,
      resultsCreated: (json['results_created'] as num?)?.toInt() ?? 0,
      resultsUpdated: (json['results_updated'] as num?)?.toInt() ?? 0,
      publishedAt: json['published_at']?.toString(),
    );
  }
}
