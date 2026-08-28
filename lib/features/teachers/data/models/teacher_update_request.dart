class TeacherUpdateRequest {
  final String? department;
  final DateTime? hireDate;
  final String? qualification;
  final String? subjectSpecializationId;

  TeacherUpdateRequest({
    this.department,
    this.hireDate,
    this.qualification,
    this.subjectSpecializationId,
  });

  Map<String, dynamic> toJson() => {
        if (department != null) 'department': department,
        if (hireDate != null) 'hire_date': hireDate!.toIso8601String().split('T').first,
        if (qualification != null) 'qualification': qualification,
        if (subjectSpecializationId != null) 'subject_specialization_id': subjectSpecializationId,
      };
}