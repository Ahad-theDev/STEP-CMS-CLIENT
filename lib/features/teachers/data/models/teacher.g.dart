// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeacherImpl _$$TeacherImplFromJson(Map<String, dynamic> json) =>
    _$TeacherImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      department: json['department'] as String?,
      hireDate: json['hire_date'] == null
          ? null
          : DateTime.parse(json['hire_date'] as String),
      qualification: json['qualification'] as String?,
      subjectSpecializationId: json['subject_specialization_id'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TeacherImplToJson(_$TeacherImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'email': instance.email,
      'department': instance.department,
      'hire_date': instance.hireDate?.toIso8601String(),
      'qualification': instance.qualification,
      'subject_specialization_id': instance.subjectSpecializationId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
