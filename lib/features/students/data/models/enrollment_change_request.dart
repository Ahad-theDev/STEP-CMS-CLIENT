
class EnrollmentChangeRequest {
  final String newClassId;
  final String academicYear;

  EnrollmentChangeRequest({required this.newClassId, required this.academicYear});

  Map<String, dynamic> toJson() => {
        'new_class_id': newClassId,
        'academic_year': academicYear,
      };
}