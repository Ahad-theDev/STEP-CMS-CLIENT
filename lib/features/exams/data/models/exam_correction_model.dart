import 'package:flutter/foundation.dart';
import 'package:cms/core/utils/numeric_utils.dart';

@immutable
class ExamResultCorrection {
  final double marksObtained;
  final bool isAbsent;
  final String reason;

  const ExamResultCorrection({
    required this.marksObtained,
    this.isAbsent = false,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'marks_obtained': isAbsent ? 0.0 : marksObtained,
    'is_absent': isAbsent,
    'reason': reason.trim(),
  };
}

@immutable
class ExamResultAudit {
  final String id;
  final String studentResultId;
  final double oldMarks;
  final double newMarks;
  final bool oldIsAbsent;
  final bool newIsAbsent;
  final String changedBy;
  final String reason;
  final String changedAt;

  const ExamResultAudit({
    required this.id,
    required this.studentResultId,
    required this.oldMarks,
    required this.newMarks,
    required this.oldIsAbsent,
    required this.newIsAbsent,
    required this.changedBy,
    required this.reason,
    required this.changedAt,
  });

  factory ExamResultAudit.fromJson(Map<String, dynamic> json) {
    return ExamResultAudit(
      id: json['id']?.toString() ?? '',
      studentResultId: json['student_result_id']?.toString() ?? '',
      oldMarks: parseDouble(json['old_marks']),
      newMarks: parseDouble(json['new_marks']),
      oldIsAbsent: json['old_is_absent'] == true,
      newIsAbsent: json['new_is_absent'] == true,
      changedBy: json['changed_by']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      changedAt: json['changed_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_result_id': studentResultId,
    'old_marks': oldMarks,
    'new_marks': newMarks,
    'old_is_absent': oldIsAbsent,
    'new_is_absent': newIsAbsent,
    'changed_by': changedBy,
    'reason': reason,
    'changed_at': changedAt,
  };
}
