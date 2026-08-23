// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Student _$StudentFromJson(Map<String, dynamic> json) {
  return _Student.fromJson(json);
}

/// @nodoc
mixin _$Student {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'roll_number')
  String get rollNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_id')
  String get classId => throw _privateConstructorUsedError;
  @JsonKey(name: 'guardian_name')
  String? get guardianName => throw _privateConstructorUsedError;
  @JsonKey(name: 'guardian_phone')
  String? get guardianPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'admission_date')
  DateTime? get admissionDate => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'monthly_fee',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double get monthlyFee => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get discount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Student to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentCopyWith<Student> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentCopyWith<$Res> {
  factory $StudentCopyWith(Student value, $Res Function(Student) then) =
      _$StudentCopyWithImpl<$Res, Student>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'roll_number') String rollNumber,
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(name: 'guardian_name') String? guardianName,
    @JsonKey(name: 'guardian_phone') String? guardianPhone,
    @JsonKey(name: 'admission_date') DateTime? admissionDate,
    @JsonKey(
      name: 'monthly_fee',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double monthlyFee,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    double discount,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$StudentCopyWithImpl<$Res, $Val extends Student>
    implements $StudentCopyWith<$Res> {
  _$StudentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? fullName = null,
    Object? rollNumber = null,
    Object? classId = null,
    Object? guardianName = freezed,
    Object? guardianPhone = freezed,
    Object? admissionDate = freezed,
    Object? monthlyFee = null,
    Object? discount = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            rollNumber: null == rollNumber
                ? _value.rollNumber
                : rollNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            guardianName: freezed == guardianName
                ? _value.guardianName
                : guardianName // ignore: cast_nullable_to_non_nullable
                      as String?,
            guardianPhone: freezed == guardianPhone
                ? _value.guardianPhone
                : guardianPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            admissionDate: freezed == admissionDate
                ? _value.admissionDate
                : admissionDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            monthlyFee: null == monthlyFee
                ? _value.monthlyFee
                : monthlyFee // ignore: cast_nullable_to_non_nullable
                      as double,
            discount: null == discount
                ? _value.discount
                : discount // ignore: cast_nullable_to_non_nullable
                      as double,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentImplCopyWith<$Res> implements $StudentCopyWith<$Res> {
  factory _$$StudentImplCopyWith(
    _$StudentImpl value,
    $Res Function(_$StudentImpl) then,
  ) = __$$StudentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'roll_number') String rollNumber,
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(name: 'guardian_name') String? guardianName,
    @JsonKey(name: 'guardian_phone') String? guardianPhone,
    @JsonKey(name: 'admission_date') DateTime? admissionDate,
    @JsonKey(
      name: 'monthly_fee',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double monthlyFee,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    double discount,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$StudentImplCopyWithImpl<$Res>
    extends _$StudentCopyWithImpl<$Res, _$StudentImpl>
    implements _$$StudentImplCopyWith<$Res> {
  __$$StudentImplCopyWithImpl(
    _$StudentImpl _value,
    $Res Function(_$StudentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? fullName = null,
    Object? rollNumber = null,
    Object? classId = null,
    Object? guardianName = freezed,
    Object? guardianPhone = freezed,
    Object? admissionDate = freezed,
    Object? monthlyFee = null,
    Object? discount = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$StudentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        rollNumber: null == rollNumber
            ? _value.rollNumber
            : rollNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        guardianName: freezed == guardianName
            ? _value.guardianName
            : guardianName // ignore: cast_nullable_to_non_nullable
                  as String?,
        guardianPhone: freezed == guardianPhone
            ? _value.guardianPhone
            : guardianPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        admissionDate: freezed == admissionDate
            ? _value.admissionDate
            : admissionDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        monthlyFee: null == monthlyFee
            ? _value.monthlyFee
            : monthlyFee // ignore: cast_nullable_to_non_nullable
                  as double,
        discount: null == discount
            ? _value.discount
            : discount // ignore: cast_nullable_to_non_nullable
                  as double,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentImpl implements _Student {
  const _$StudentImpl({
    required this.id,
    @JsonKey(name: 'user_id') this.userId,
    @JsonKey(name: 'full_name') required this.fullName,
    @JsonKey(name: 'roll_number') required this.rollNumber,
    @JsonKey(name: 'class_id') required this.classId,
    @JsonKey(name: 'guardian_name') this.guardianName,
    @JsonKey(name: 'guardian_phone') this.guardianPhone,
    @JsonKey(name: 'admission_date') this.admissionDate,
    @JsonKey(
      name: 'monthly_fee',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    required this.monthlyFee,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required this.discount,
    @JsonKey(name: 'is_active') required this.isActive,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$StudentImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'roll_number')
  final String rollNumber;
  @override
  @JsonKey(name: 'class_id')
  final String classId;
  @override
  @JsonKey(name: 'guardian_name')
  final String? guardianName;
  @override
  @JsonKey(name: 'guardian_phone')
  final String? guardianPhone;
  @override
  @JsonKey(name: 'admission_date')
  final DateTime? admissionDate;
  @override
  @JsonKey(
    name: 'monthly_fee',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  final double monthlyFee;
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  final double discount;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Student(id: $id, userId: $userId, fullName: $fullName, rollNumber: $rollNumber, classId: $classId, guardianName: $guardianName, guardianPhone: $guardianPhone, admissionDate: $admissionDate, monthlyFee: $monthlyFee, discount: $discount, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.rollNumber, rollNumber) ||
                other.rollNumber == rollNumber) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.guardianName, guardianName) ||
                other.guardianName == guardianName) &&
            (identical(other.guardianPhone, guardianPhone) ||
                other.guardianPhone == guardianPhone) &&
            (identical(other.admissionDate, admissionDate) ||
                other.admissionDate == admissionDate) &&
            (identical(other.monthlyFee, monthlyFee) ||
                other.monthlyFee == monthlyFee) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    fullName,
    rollNumber,
    classId,
    guardianName,
    guardianPhone,
    admissionDate,
    monthlyFee,
    discount,
    isActive,
    createdAt,
  );

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      __$$StudentImplCopyWithImpl<_$StudentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentImplToJson(this);
  }
}

abstract class _Student implements Student {
  const factory _Student({
    required final String id,
    @JsonKey(name: 'user_id') final String? userId,
    @JsonKey(name: 'full_name') required final String fullName,
    @JsonKey(name: 'roll_number') required final String rollNumber,
    @JsonKey(name: 'class_id') required final String classId,
    @JsonKey(name: 'guardian_name') final String? guardianName,
    @JsonKey(name: 'guardian_phone') final String? guardianPhone,
    @JsonKey(name: 'admission_date') final DateTime? admissionDate,
    @JsonKey(
      name: 'monthly_fee',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    required final double monthlyFee,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required final double discount,
    @JsonKey(name: 'is_active') required final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$StudentImpl;

  factory _Student.fromJson(Map<String, dynamic> json) = _$StudentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'roll_number')
  String get rollNumber;
  @override
  @JsonKey(name: 'class_id')
  String get classId;
  @override
  @JsonKey(name: 'guardian_name')
  String? get guardianName;
  @override
  @JsonKey(name: 'guardian_phone')
  String? get guardianPhone;
  @override
  @JsonKey(name: 'admission_date')
  DateTime? get admissionDate;
  @override
  @JsonKey(
    name: 'monthly_fee',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double get monthlyFee;
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get discount;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
