import 'bulk_import_error.dart';

class BulkImportResult {
  final int total;
  final int success;
  final int failed;
  final List<BulkImportError> errors;

  BulkImportResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.errors,
  });

  factory BulkImportResult.fromJson(Map<String, dynamic> json) => BulkImportResult(
        total: json['total'] as int,
        success: json['success'] as int,
        failed: json['failed'] as int,
        errors: (json['errors'] as List)
            .map((e) => BulkImportError.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}