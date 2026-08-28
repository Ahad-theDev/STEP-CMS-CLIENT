class ClassCreateRequest {
  final String name;
  final String section;
  final String academicYear;
  final String? classTeacherId;

  ClassCreateRequest({
    required this.name,
    required this.section,
    required this.academicYear,
    this.classTeacherId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'section': section,
        'academic_year': academicYear,
        if (classTeacherId != null && classTeacherId!.isNotEmpty)
          'class_teacher_id': classTeacherId,
      };
}