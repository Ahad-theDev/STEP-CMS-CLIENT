class StudentUpdateRequest {
  final String? fullName;
  final String? rollNumber;
  final String? guardianName;
  final String? guardianPhone;
  final double? monthlyFee;
  final double? discount;

  StudentUpdateRequest({
    this.fullName,
    this.rollNumber,
    this.guardianName,
    this.guardianPhone,
    this.monthlyFee,
    this.discount,
  });

  Map<String, dynamic> toJson() => {
        if (fullName != null) 'full_name': fullName,
        if (rollNumber != null) 'roll_number': rollNumber,
        if (guardianName != null) 'guardian_name': guardianName,
        if (guardianPhone != null) 'guardian_phone': guardianPhone,
        if (monthlyFee != null) 'monthly_fee': monthlyFee,
        if (discount != null) 'discount': discount,
      };
}