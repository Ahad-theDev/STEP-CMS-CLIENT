class SubjectUpdateRequest {
  final String? name;
  final String? code;

  SubjectUpdateRequest({this.name, this.code});

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (code != null) 'code': code,
      };
}