import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_class.freezed.dart';
part 'school_class.g.dart';

@freezed
class SchoolClass with _$SchoolClass {
  const factory SchoolClass({
    required String id,
    required String name,
    required String section,
    @JsonKey(name: 'academic_year') required String academicYear,
    @JsonKey(name: 'class_teacher_id') String? classTeacherId,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SchoolClass;

  factory SchoolClass.fromJson(Map<String, dynamic> json) => _$SchoolClassFromJson(json);
}