// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Teacher _$TeacherFromJson(Map<String, dynamic> json) {
  return _Teacher.fromJson(json);
}

/// @nodoc
mixin _$Teacher {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  @JsonKey(name: 'hire_date')
  DateTime? get hireDate => throw _privateConstructorUsedError;
  String? get qualification => throw _privateConstructorUsedError;
  @JsonKey(name: 'subject_specialization_id')
  String? get subjectSpecializationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Teacher to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherCopyWith<Teacher> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherCopyWith<$Res> {
  factory $TeacherCopyWith(Teacher value, $Res Function(Teacher) then) =
      _$TeacherCopyWithImpl<$Res, Teacher>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'full_name') String fullName,
    String email,
    String? department,
    @JsonKey(name: 'hire_date') DateTime? hireDate,
    String? qualification,
    @JsonKey(name: 'subject_specialization_id') String? subjectSpecializationId,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$TeacherCopyWithImpl<$Res, $Val extends Teacher>
    implements $TeacherCopyWith<$Res> {
  _$TeacherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fullName = null,
    Object? email = null,
    Object? department = freezed,
    Object? hireDate = freezed,
    Object? qualification = freezed,
    Object? subjectSpecializationId = freezed,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            department: freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String?,
            hireDate: freezed == hireDate
                ? _value.hireDate
                : hireDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            qualification: freezed == qualification
                ? _value.qualification
                : qualification // ignore: cast_nullable_to_non_nullable
                      as String?,
            subjectSpecializationId: freezed == subjectSpecializationId
                ? _value.subjectSpecializationId
                : subjectSpecializationId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$TeacherImplCopyWith<$Res> implements $TeacherCopyWith<$Res> {
  factory _$$TeacherImplCopyWith(
    _$TeacherImpl value,
    $Res Function(_$TeacherImpl) then,
  ) = __$$TeacherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'full_name') String fullName,
    String email,
    String? department,
    @JsonKey(name: 'hire_date') DateTime? hireDate,
    String? qualification,
    @JsonKey(name: 'subject_specialization_id') String? subjectSpecializationId,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$TeacherImplCopyWithImpl<$Res>
    extends _$TeacherCopyWithImpl<$Res, _$TeacherImpl>
    implements _$$TeacherImplCopyWith<$Res> {
  __$$TeacherImplCopyWithImpl(
    _$TeacherImpl _value,
    $Res Function(_$TeacherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fullName = null,
    Object? email = null,
    Object? department = freezed,
    Object? hireDate = freezed,
    Object? qualification = freezed,
    Object? subjectSpecializationId = freezed,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$TeacherImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        department: freezed == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String?,
        hireDate: freezed == hireDate
            ? _value.hireDate
            : hireDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        qualification: freezed == qualification
            ? _value.qualification
            : qualification // ignore: cast_nullable_to_non_nullable
                  as String?,
        subjectSpecializationId: freezed == subjectSpecializationId
            ? _value.subjectSpecializationId
            : subjectSpecializationId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$TeacherImpl implements _Teacher {
  const _$TeacherImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'full_name') required this.fullName,
    required this.email,
    this.department,
    @JsonKey(name: 'hire_date') this.hireDate,
    this.qualification,
    @JsonKey(name: 'subject_specialization_id') this.subjectSpecializationId,
    @JsonKey(name: 'is_active') required this.isActive,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$TeacherImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String email;
  @override
  final String? department;
  @override
  @JsonKey(name: 'hire_date')
  final DateTime? hireDate;
  @override
  final String? qualification;
  @override
  @JsonKey(name: 'subject_specialization_id')
  final String? subjectSpecializationId;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Teacher(id: $id, userId: $userId, fullName: $fullName, email: $email, department: $department, hireDate: $hireDate, qualification: $qualification, subjectSpecializationId: $subjectSpecializationId, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.hireDate, hireDate) ||
                other.hireDate == hireDate) &&
            (identical(other.qualification, qualification) ||
                other.qualification == qualification) &&
            (identical(
                  other.subjectSpecializationId,
                  subjectSpecializationId,
                ) ||
                other.subjectSpecializationId == subjectSpecializationId) &&
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
    email,
    department,
    hireDate,
    qualification,
    subjectSpecializationId,
    isActive,
    createdAt,
  );

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherImplCopyWith<_$TeacherImpl> get copyWith =>
      __$$TeacherImplCopyWithImpl<_$TeacherImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherImplToJson(this);
  }
}

abstract class _Teacher implements Teacher {
  const factory _Teacher({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'full_name') required final String fullName,
    required final String email,
    final String? department,
    @JsonKey(name: 'hire_date') final DateTime? hireDate,
    final String? qualification,
    @JsonKey(name: 'subject_specialization_id')
    final String? subjectSpecializationId,
    @JsonKey(name: 'is_active') required final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$TeacherImpl;

  factory _Teacher.fromJson(Map<String, dynamic> json) = _$TeacherImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  String get email;
  @override
  String? get department;
  @override
  @JsonKey(name: 'hire_date')
  DateTime? get hireDate;
  @override
  String? get qualification;
  @override
  @JsonKey(name: 'subject_specialization_id')
  String? get subjectSpecializationId;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherImplCopyWith<_$TeacherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
