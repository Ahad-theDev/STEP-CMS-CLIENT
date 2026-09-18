class BulkGenerateFeesRequest {
  final List<String> classIds;
  final int month;
  final int year;

  BulkGenerateFeesRequest({required this.classIds, required this.month, required this.year});

  Map<String, dynamic> toJson() => {'class_ids': classIds, 'month': month, 'year': year};
}

class SingleGenerateFeeRequest {
  final int month;
  final int year;

  SingleGenerateFeeRequest({required this.month, required this.year});

  Map<String, dynamic> toJson() => {'month': month, 'year': year};
}