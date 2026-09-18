// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_structure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeeStructure _$FeeStructureFromJson(Map<String, dynamic> json) {
  return _FeeStructure.fromJson(json);
}

/// @nodoc
mixin _$FeeStructure {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_id')
  String get classId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_year')
  String get academicYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this FeeStructure to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeeStructure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeeStructureCopyWith<FeeStructure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeStructureCopyWith<$Res> {
  factory $FeeStructureCopyWith(
    FeeStructure value,
    $Res Function(FeeStructure) then,
  ) = _$FeeStructureCopyWithImpl<$Res, FeeStructure>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) double amount,
    @JsonKey(name: 'academic_year') String academicYear,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class _$FeeStructureCopyWithImpl<$Res, $Val extends FeeStructure>
    implements $FeeStructureCopyWith<$Res> {
  _$FeeStructureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeeStructure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classId = null,
    Object? amount = null,
    Object? academicYear = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            academicYear: null == academicYear
                ? _value.academicYear
                : academicYear // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeeStructureImplCopyWith<$Res>
    implements $FeeStructureCopyWith<$Res> {
  factory _$$FeeStructureImplCopyWith(
    _$FeeStructureImpl value,
    $Res Function(_$FeeStructureImpl) then,
  ) = __$$FeeStructureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'class_id') String classId,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) double amount,
    @JsonKey(name: 'academic_year') String academicYear,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class __$$FeeStructureImplCopyWithImpl<$Res>
    extends _$FeeStructureCopyWithImpl<$Res, _$FeeStructureImpl>
    implements _$$FeeStructureImplCopyWith<$Res> {
  __$$FeeStructureImplCopyWithImpl(
    _$FeeStructureImpl _value,
    $Res Function(_$FeeStructureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeeStructure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classId = null,
    Object? amount = null,
    Object? academicYear = null,
    Object? isActive = null,
  }) {
    return _then(
      _$FeeStructureImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        academicYear: null == academicYear
            ? _value.academicYear
            : academicYear // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeeStructureImpl implements _FeeStructure {
  const _$FeeStructureImpl({
    required this.id,
    @JsonKey(name: 'class_id') required this.classId,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required this.amount,
    @JsonKey(name: 'academic_year') required this.academicYear,
    @JsonKey(name: 'is_active') required this.isActive,
  });

  factory _$FeeStructureImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeeStructureImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'class_id')
  final String classId;
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  final double amount;
  @override
  @JsonKey(name: 'academic_year')
  final String academicYear;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'FeeStructure(id: $id, classId: $classId, amount: $amount, academicYear: $academicYear, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeStructureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, classId, amount, academicYear, isActive);

  /// Create a copy of FeeStructure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeStructureImplCopyWith<_$FeeStructureImpl> get copyWith =>
      __$$FeeStructureImplCopyWithImpl<_$FeeStructureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeeStructureImplToJson(this);
  }
}

abstract class _FeeStructure implements FeeStructure {
  const factory _FeeStructure({
    required final String id,
    @JsonKey(name: 'class_id') required final String classId,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required final double amount,
    @JsonKey(name: 'academic_year') required final String academicYear,
    @JsonKey(name: 'is_active') required final bool isActive,
  }) = _$FeeStructureImpl;

  factory _FeeStructure.fromJson(Map<String, dynamic> json) =
      _$FeeStructureImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'class_id')
  String get classId;
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get amount;
  @override
  @JsonKey(name: 'academic_year')
  String get academicYear;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of FeeStructure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeStructureImplCopyWith<_$FeeStructureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
