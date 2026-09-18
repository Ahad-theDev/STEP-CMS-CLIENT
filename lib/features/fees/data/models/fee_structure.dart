import 'package:freezed_annotation/freezed_annotation.dart';

part 'fee_structure.freezed.dart';
part 'fee_structure.g.dart';

double _decimalFromJson(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  throw FormatException('Cannot parse decimal value: $value');
}

dynamic _decimalToJson(double value) => value;

@freezed
class FeeStructure with _$FeeStructure {
  const factory FeeStructure({
    required String id,
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required double amount,
    @JsonKey(name: 'academic_year') required String academicYear,
    @JsonKey(name: 'is_active') required bool isActive,
  }) = _FeeStructure;

  factory FeeStructure.fromJson(Map<String, dynamic> json) => _$FeeStructureFromJson(json);
}