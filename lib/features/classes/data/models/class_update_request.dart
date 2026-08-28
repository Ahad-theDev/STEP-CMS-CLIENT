class ClassUpdateRequest {
  final String? name;
  final String? section;
  final String? academicYear;

  ClassUpdateRequest({this.name, this.section, this.academicYear});

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (section != null) 'section': section,
        if (academicYear != null) 'academic_year': academicYear,
      };
}