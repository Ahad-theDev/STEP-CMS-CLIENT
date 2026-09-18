class FeeStructureCreateRequest {
  final String classId;
  final double amount;
  final String academicYear;

  FeeStructureCreateRequest({required this.classId, required this.amount, required this.academicYear});

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'amount': amount,
        'academic_year': academicYear,
      };
}