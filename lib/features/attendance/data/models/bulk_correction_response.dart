class CorrectionResultItem {
  final String studentId;
  final String actionTaken; // corrected | added | skipped_not_found | skipped_duplicate

  CorrectionResultItem({required this.studentId, required this.actionTaken});

  factory CorrectionResultItem.fromJson(Map<String, dynamic> json) => CorrectionResultItem(
        studentId: json['student_id'] as String,
        actionTaken: json['action_taken'] as String,
      );
}

class BulkCorrectionResponse {
  final List<CorrectionResultItem> results;
  final int auditRowsWritten;

  BulkCorrectionResponse({required this.results, required this.auditRowsWritten});

  factory BulkCorrectionResponse.fromJson(Map<String, dynamic> json) => BulkCorrectionResponse(
        results: (json['results'] as List)
            .map((e) => CorrectionResultItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        auditRowsWritten: json['audit_rows_written'] as int,
      );
}