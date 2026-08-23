class StudentCreateRequest {
  final String? userId;
  final String fullName;
  final String rollNumber;
  final String classId;
  final String guardianName;
  final String guardianPhone;
  final DateTime admissionDate;
  final double monthlyFee;
  final double discount;

  StudentCreateRequest({
    this.userId,
    required this.fullName,
    required this.rollNumber,
    required this.classId,
    required this.guardianName,
    required this.guardianPhone,
    required this.admissionDate,
    required this.monthlyFee,
    this.discount = 0,
  });

  Map<String, dynamic> toJson() => {
        if (userId != null) 'user_id': userId,
        'full_name': fullName,
        'roll_number': rollNumber,
        'class_id': classId,
        'guardian_name': guardianName,
        'guardian_phone': guardianPhone,
        'admission_date': admissionDate.toIso8601String().split('T').first,
        'monthly_fee': monthlyFee,
        'discount': discount,
      };
}