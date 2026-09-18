class FeeGenerateError {
  final String studentId;
  final String reason;

  FeeGenerateError({required this.studentId, required this.reason});

  factory FeeGenerateError.fromJson(Map<String, dynamic> json) => FeeGenerateError(
        studentId: json['student_id'] as String,
        reason: json['reason'] as String,
      );
}

class FeeGenerateResult {
  final int total;
  final int success;
  final int failed;
  final int skipped;
  final List<FeeGenerateError> errors;

  FeeGenerateResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.skipped,
    required this.errors,
  });

  factory FeeGenerateResult.fromJson(Map<String, dynamic> json) => FeeGenerateResult(
        total: json['total'] as int,
        success: json['success'] as int,
        failed: json['failed'] as int,
        skipped: json['skipped'] as int,
        errors: (json['errors'] as List)
            .map((e) => FeeGenerateError.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}