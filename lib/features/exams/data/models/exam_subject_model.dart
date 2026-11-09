import 'package:flutter/foundation.dart';
import 'package:cms/core/utils/numeric_utils.dart';

@immutable
class ExamSubject {
  final String id;
  final String examId;
  final String? subjectId;
  final String subjectName;
  final String? subjectCode;
  final double maxMarks;
  final double passingMarks;
  final int displayOrder;
  final String? remarks;

  const ExamSubject({
    required this.id,
    required this.examId,
    this.subjectId,
    required this.subjectName,
    this.subjectCode,
    required this.maxMarks,
    required this.passingMarks,
    this.displayOrder = 0,
    this.remarks,
  });

  factory ExamSubject.fromJson(Map<String, dynamic> json) {
    return ExamSubject(
      id: json['id']?.toString() ?? '',
      examId: json['exam_id']?.toString() ?? '',
      subjectId: json['subject_id']?.toString(),
      subjectName: json['subject_name']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString(),
      maxMarks: parseDouble(json['max_marks'], 100.0),
      passingMarks: parseDouble(json['passing_marks'], 33.0),
      displayOrder: parseInt(json['display_order'], 0),
      remarks: json['remarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exam_id': examId,
    'subject_id': subjectId,
    'subject_name': subjectName,
    'subject_code': subjectCode,
    'max_marks': maxMarks,
    'passing_marks': passingMarks,
    'display_order': displayOrder,
    'remarks': remarks,
  };
}

@immutable
class ExamSubjectCreate {
  final String? subjectId;
  final String subjectName;
  final String? subjectCode;
  final double maxMarks;
  final double passingMarks;
  final int displayOrder;
  final String? remarks;

  const ExamSubjectCreate({
    this.subjectId,
    required this.subjectName,
    this.subjectCode,
    required this.maxMarks,
    required this.passingMarks,
    this.displayOrder = 0,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'subject_name': subjectName.trim(),
      'max_marks': maxMarks,
      'passing_marks': passingMarks,
      'display_order': displayOrder,
    };
    if (subjectId != null && subjectId!.trim().isNotEmpty) {
      map['subject_id'] = subjectId!.trim();
    }
    if (subjectCode != null && subjectCode!.trim().isNotEmpty) {
      map['subject_code'] = subjectCode!.trim();
    }
    if (remarks != null && remarks!.trim().isNotEmpty) {
      map['remarks'] = remarks!.trim();
    }
    return map;
  }
}

@immutable
class ExamSubjectUpdate {
  final String? id;
  final String? subjectId;
  final String subjectName;
  final String? subjectCode;
  final double maxMarks;
  final double passingMarks;
  final int displayOrder;
  final String? remarks;

  const ExamSubjectUpdate({
    this.id,
    this.subjectId,
    required this.subjectName,
    this.subjectCode,
    required this.maxMarks,
    required this.passingMarks,
    this.displayOrder = 0,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'subject_name': subjectName.trim(),
      'max_marks': maxMarks,
      'passing_marks': passingMarks,
      'display_order': displayOrder,
    };
    if (id != null && id!.trim().isNotEmpty) {
      map['id'] = id!.trim();
    }
    if (subjectId != null && subjectId!.trim().isNotEmpty) {
      map['subject_id'] = subjectId!.trim();
    }
    if (subjectCode != null && subjectCode!.trim().isNotEmpty) {
      map['subject_code'] = subjectCode!.trim();
    }
    if (remarks != null && remarks!.trim().isNotEmpty) {
      map['remarks'] = remarks!.trim();
    }
    return map;
  }
}
