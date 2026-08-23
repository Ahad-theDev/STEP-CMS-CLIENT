

import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';
part 'student.g.dart';


double _decimalFromJson(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  throw FormatException("Cannot parse decimal value: $value");
}

dynamic _decimalToJson(double value) => value;


@freezed
class Student with _$Student {
  const factory Student({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'roll_number') required String rollNumber,
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'guardian_name') String? guardianName,
    @JsonKey(name: 'guardian_phone') String? guardianPhone,
    @JsonKey(name: 'admission_date') DateTime? admissionDate,
    @JsonKey(name: 'monthly_fee', fromJson: _decimalFromJson, toJson: _decimalToJson)
    required double monthlyFee,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required double discount,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
}
