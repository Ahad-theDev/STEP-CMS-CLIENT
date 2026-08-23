// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentImpl _$$StudentImplFromJson(Map<String, dynamic> json) =>
    _$StudentImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String,
      rollNumber: json['roll_number'] as String,
      classId: json['class_id'] as String,
      guardianName: json['guardian_name'] as String?,
      guardianPhone: json['guardian_phone'] as String?,
      admissionDate: json['admission_date'] == null
          ? null
          : DateTime.parse(json['admission_date'] as String),
      monthlyFee: _decimalFromJson(json['monthly_fee']),
      discount: _decimalFromJson(json['discount']),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$StudentImplToJson(_$StudentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'roll_number': instance.rollNumber,
      'class_id': instance.classId,
      'guardian_name': instance.guardianName,
      'guardian_phone': instance.guardianPhone,
      'admission_date': instance.admissionDate?.toIso8601String(),
      'monthly_fee': _decimalToJson(instance.monthlyFee),
      'discount': _decimalToJson(instance.discount),
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
