class TeacherCreateRequest {
  final String userId;
  final String department;
  final DateTime hireDate;
  final String? qualification;
  final String? subjectSpecializationId;

  TeacherCreateRequest({
    required this.userId,
    required this.department,
    required this.hireDate,
    this.qualification,
    this.subjectSpecializationId,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'department': department,
        'hire_date': hireDate.toIso8601String().split('T').first, // YYYY-MM-DD
        if (qualification != null && qualification!.isNotEmpty)
          'qualification': qualification,
        if (subjectSpecializationId != null && subjectSpecializationId!.isNotEmpty)
          'subject_specialization_id': subjectSpecializationId,
      };
}