// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SchoolClassImpl _$$SchoolClassImplFromJson(Map<String, dynamic> json) =>
    _$SchoolClassImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      section: json['section'] as String,
      academicYear: json['academic_year'] as String,
      classTeacherId: json['class_teacher_id'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SchoolClassImplToJson(_$SchoolClassImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'section': instance.section,
      'academic_year': instance.academicYear,
      'class_teacher_id': instance.classTeacherId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
