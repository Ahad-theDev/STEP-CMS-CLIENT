class AssignTeacherRequest {
  final String teacherId;
  AssignTeacherRequest({required this.teacherId});
  Map<String, dynamic> toJson() => {'teacher_id': teacherId};
}