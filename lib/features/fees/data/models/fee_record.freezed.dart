// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeeRecord _$FeeRecordFromJson(Map<String, dynamic> json) {
  return _FeeRecord.fromJson(json);
}

/// @nodoc
mixin _$FeeRecord {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'amount_due',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double get amountDue => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'amount_paid',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double get amountPaid => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_date')
  String? get paymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this FeeRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeeRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeeRecordCopyWith<FeeRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeRecordCopyWith<$Res> {
  factory $FeeRecordCopyWith(FeeRecord value, $Res Function(FeeRecord) then) =
      _$FeeRecordCopyWithImpl<$Res, FeeRecord>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'student_id') String studentId,
    int month,
    int year,
    @JsonKey(
      name: 'amount_due',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double amountDue,
    @JsonKey(
      name: 'amount_paid',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double amountPaid,
    String status,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$FeeRecordCopyWithImpl<$Res, $Val extends FeeRecord>
    implements $FeeRecordCopyWith<$Res> {
  _$FeeRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeeRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? month = null,
    Object? year = null,
    Object? amountDue = null,
    Object? amountPaid = null,
    Object? status = null,
    Object? paymentDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as int,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            amountDue: null == amountDue
                ? _value.amountDue
                : amountDue // ignore: cast_nullable_to_non_nullable
                      as double,
            amountPaid: null == amountPaid
                ? _value.amountPaid
                : amountPaid // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentDate: freezed == paymentDate
                ? _value.paymentDate
                : paymentDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeeRecordImplCopyWith<$Res>
    implements $FeeRecordCopyWith<$Res> {
  factory _$$FeeRecordImplCopyWith(
    _$FeeRecordImpl value,
    $Res Function(_$FeeRecordImpl) then,
  ) = __$$FeeRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'student_id') String studentId,
    int month,
    int year,
    @JsonKey(
      name: 'amount_due',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double amountDue,
    @JsonKey(
      name: 'amount_paid',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double amountPaid,
    String status,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$FeeRecordImplCopyWithImpl<$Res>
    extends _$FeeRecordCopyWithImpl<$Res, _$FeeRecordImpl>
    implements _$$FeeRecordImplCopyWith<$Res> {
  __$$FeeRecordImplCopyWithImpl(
    _$FeeRecordImpl _value,
    $Res Function(_$FeeRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeeRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? month = null,
    Object? year = null,
    Object? amountDue = null,
    Object? amountPaid = null,
    Object? status = null,
    Object? paymentDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$FeeRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as int,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        amountDue: null == amountDue
            ? _value.amountDue
            : amountDue // ignore: cast_nullable_to_non_nullable
                  as double,
        amountPaid: null == amountPaid
            ? _value.amountPaid
            : amountPaid // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentDate: freezed == paymentDate
            ? _value.paymentDate
            : paymentDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeeRecordImpl implements _FeeRecord {
  const _$FeeRecordImpl({
    required this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    required this.month,
    required this.year,
    @JsonKey(
      name: 'amount_due',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    required this.amountDue,
    @JsonKey(
      name: 'amount_paid',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    required this.amountPaid,
    required this.status,
    @JsonKey(name: 'payment_date') this.paymentDate,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$FeeRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeeRecordImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'student_id')
  final String studentId;
  @override
  final int month;
  @override
  final int year;
  @override
  @JsonKey(
    name: 'amount_due',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  final double amountDue;
  @override
  @JsonKey(
    name: 'amount_paid',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  final double amountPaid;
  @override
  final String status;
  @override
  @JsonKey(name: 'payment_date')
  final String? paymentDate;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'FeeRecord(id: $id, studentId: $studentId, month: $month, year: $year, amountDue: $amountDue, amountPaid: $amountPaid, status: $status, paymentDate: $paymentDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.amountDue, amountDue) ||
                other.amountDue == amountDue) &&
            (identical(other.amountPaid, amountPaid) ||
                other.amountPaid == amountPaid) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    month,
    year,
    amountDue,
    amountPaid,
    status,
    paymentDate,
    createdAt,
    updatedAt,
  );

  /// Create a copy of FeeRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeRecordImplCopyWith<_$FeeRecordImpl> get copyWith =>
      __$$FeeRecordImplCopyWithImpl<_$FeeRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeeRecordImplToJson(this);
  }
}

abstract class _FeeRecord implements FeeRecord {
  const factory _FeeRecord({
    required final String id,
    @JsonKey(name: 'student_id') required final String studentId,
    required final int month,
    required final int year,
    @JsonKey(
      name: 'amount_due',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    required final double amountDue,
    @JsonKey(
      name: 'amount_paid',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    required final double amountPaid,
    required final String status,
    @JsonKey(name: 'payment_date') final String? paymentDate,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$FeeRecordImpl;

  factory _FeeRecord.fromJson(Map<String, dynamic> json) =
      _$FeeRecordImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'student_id')
  String get studentId;
  @override
  int get month;
  @override
  int get year;
  @override
  @JsonKey(
    name: 'amount_due',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double get amountDue;
  @override
  @JsonKey(
    name: 'amount_paid',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double get amountPaid;
  @override
  String get status;
  @override
  @JsonKey(name: 'payment_date')
  String? get paymentDate;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of FeeRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeRecordImplCopyWith<_$FeeRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
