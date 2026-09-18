// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeeRecordImpl _$$FeeRecordImplFromJson(Map<String, dynamic> json) =>
    _$FeeRecordImpl(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      amountDue: _decimalFromJson(json['amount_due']),
      amountPaid: _decimalFromJson(json['amount_paid']),
      status: json['status'] as String,
      paymentDate: json['payment_date'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$FeeRecordImplToJson(_$FeeRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'month': instance.month,
      'year': instance.year,
      'amount_due': _decimalToJson(instance.amountDue),
      'amount_paid': _decimalToJson(instance.amountPaid),
      'status': instance.status,
      'payment_date': instance.paymentDate,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
