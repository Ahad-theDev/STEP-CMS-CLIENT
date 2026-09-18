// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_structure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeeStructureImpl _$$FeeStructureImplFromJson(Map<String, dynamic> json) =>
    _$FeeStructureImpl(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      amount: _decimalFromJson(json['amount']),
      academicYear: json['academic_year'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$$FeeStructureImplToJson(_$FeeStructureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_id': instance.classId,
      'amount': _decimalToJson(instance.amount),
      'academic_year': instance.academicYear,
      'is_active': instance.isActive,
    };
