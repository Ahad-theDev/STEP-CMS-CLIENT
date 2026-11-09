import 'package:flutter/foundation.dart';
import 'package:cms/core/utils/numeric_utils.dart';

enum ExamType {
  midTerm('mid_term', 'Mid Term'),
  finalTerm('final_term', 'Final Term'),
  regular('regular', 'Regular');

  final String value;
  final String label;
  const ExamType(this.value, this.label);

  static ExamType fromString(String val) {
    return ExamType.values.firstWhere(
      (e) => e.value == val.toLowerCase().trim(),
      orElse: () => ExamType.regular,
    );
  }
}

enum ExamStatus {
  draft('draft', 'Draft'),
  published('published', 'Published');

  final String value;
  final String label;
  const ExamStatus(this.value, this.label);

  static ExamStatus fromString(String val) {
    return ExamStatus.values.firstWhere(
      (e) => e.value == val.toLowerCase().trim(),
      orElse: () => ExamStatus.draft,
    );
  }
}

@immutable
class Exam {
  final String id;
  final String classId;
  final String title;
  final ExamType examType;
  final String academicYear;
  final String? termName;
  final String? examDate;
  final String? description;
  final ExamStatus status;
  final String createdBy;
  final String? publishedAt;
  final String createdAt;
  final String updatedAt;
  final int studentCount;
  final String? className;
  final String? section;

  const Exam({
    required this.id,
    required this.classId,
    required this.title,
    required this.examType,
    required this.academicYear,
    this.termName,
    this.examDate,
    this.description,
    required this.status,
    required this.createdBy,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.studentCount = 0,
    this.className,
    this.section,
  });

  bool get isPublished => status == ExamStatus.published;
  bool get isDraft => status == ExamStatus.draft;

  factory Exam.fromJson(Map<String, dynamic> json) {
    // If nested class object is present
    String? cName;
    String? cSection;
    if (json['class'] is Map<String, dynamic>) {
      final cMap = json['class'] as Map<String, dynamic>;
      cName = cMap['name']?.toString();
      cSection = cMap['section']?.toString();
    }

    return Exam(
      id: json['id']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      examType: ExamType.fromString(json['exam_type']?.toString() ?? ''),
      academicYear: json['academic_year']?.toString() ?? '',
      termName: json['term_name']?.toString(),
      examDate: json['exam_date']?.toString(),
      description: json['description']?.toString(),
      status: ExamStatus.fromString(json['status']?.toString() ?? ''),
      createdBy: json['created_by']?.toString() ?? '',
      publishedAt: json['published_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      studentCount: parseInt(json['student_count']),
      className: cName ?? json['class_name']?.toString(),
      section: cSection ?? json['section']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'class_id': classId,
    'title': title,
    'exam_type': examType.value,
    'academic_year': academicYear,
    'term_name': termName,
    'exam_date': examDate,
    'description': description,
    'status': status.value,
    'created_by': createdBy,
    'published_at': publishedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'student_count': studentCount,
  };
}

@immutable
class ExamListResponse {
  final List<Exam> items;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const ExamListResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory ExamListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ExamListResponse(
      items: rawItems
          .map((e) => Exam.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: parseInt(json['page'], 1),
      limit: parseInt(json['limit'], 20),
      total: parseInt(json['total'], 0),
      pages: parseInt(json['pages'], 0),
    );
  }
}

@immutable
class ExamCreateRequest {
  final String classId;
  final String title;
  final ExamType examType;
  final String academicYear;
  final String? termName;
  final String? examDate;
  final String? description;

  const ExamCreateRequest({
    required this.classId,
    required this.title,
    required this.examType,
    required this.academicYear,
    this.termName,
    this.examDate,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'class_id': classId,
      'title': title.trim(),
      'exam_type': examType.value,
      'academic_year': academicYear.trim(),
    };
    if (termName != null && termName!.trim().isNotEmpty) {
      map['term_name'] = termName!.trim();
    }
    if (examDate != null && examDate!.trim().isNotEmpty) {
      map['exam_date'] = examDate!.trim();
    }
    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description!.trim();
    }
    return map;
  }
}
