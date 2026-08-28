import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher.freezed.dart';
part 'teacher.g.dart';

/// Mirrors TeacherOut from the backend.
@freezed
class Teacher with _$Teacher {
  const factory Teacher({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    String? department,
    @JsonKey(name: 'hire_date') DateTime? hireDate,
    String? qualification,
    @JsonKey(name: 'subject_specialization_id') String? subjectSpecializationId,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Teacher;

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);
}