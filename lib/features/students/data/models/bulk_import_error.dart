class BulkImportError {
  final int row;
  final String error;

  BulkImportError({required this.row, required this.error});

  factory BulkImportError.fromJson(Map<String, dynamic> json) => BulkImportError(
        row: json['row'] as int,
        error: json['error'] as String,
      );
}