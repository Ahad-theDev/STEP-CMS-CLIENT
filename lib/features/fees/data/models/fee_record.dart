import 'package:freezed_annotation/freezed_annotation.dart';

part 'fee_record.freezed.dart';
part 'fee_record.g.dart';

double _decimalFromJson(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  throw FormatException('Cannot parse decimal value: $value');
}

dynamic _decimalToJson(double value) => value;

@freezed
class FeeRecord with _$FeeRecord {
  const factory FeeRecord({
    required String id,
    @JsonKey(name: 'student_id') required String studentId,
    required int month,
    required int year,
    @JsonKey(name: 'amount_due', fromJson: _decimalFromJson, toJson: _decimalToJson)
    required double amountDue,
    @JsonKey(name: 'amount_paid', fromJson: _decimalFromJson, toJson: _decimalToJson)
    required double amountPaid,
    required String status,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _FeeRecord;

  factory FeeRecord.fromJson(Map<String, dynamic> json) => _$FeeRecordFromJson(json);
}