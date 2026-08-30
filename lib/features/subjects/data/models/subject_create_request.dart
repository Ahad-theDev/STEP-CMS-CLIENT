class SubjectCreateRequest {
  final String name;
  final String code;

  SubjectCreateRequest({required this.name, required this.code});

  Map<String, dynamic> toJson() => {'name': name, 'code': code};
}