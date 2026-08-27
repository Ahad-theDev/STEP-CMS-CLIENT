class StaffCreateRequest {
  final String? userId;
  final String fullName;
  final String? designation;
  final DateTime? joinDate;

  StaffCreateRequest({
    this.userId,
    required this.fullName,
    this.designation,
    this.joinDate,
  });

  Map<String, dynamic> toJson() => {
        if (userId != null && userId!.isNotEmpty) 'user_id': userId,
        'full_name': fullName,
        if (designation != null && designation!.isNotEmpty) 'designation': designation,
        if (joinDate != null) 'join_date': joinDate!.toIso8601String().split('T').first,
      };
}