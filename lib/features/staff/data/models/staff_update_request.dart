class StaffUpdateRequest {
  final String? fullName;
  final String? designation;
  final DateTime? joinDate;

  StaffUpdateRequest({this.fullName, this.designation, this.joinDate});

  Map<String, dynamic> toJson() => {
        if (fullName != null) 'full_name': fullName,
        if (designation != null) 'designation': designation,
        if (joinDate != null) 'join_date': joinDate!.toIso8601String().split('T').first,
      };
}