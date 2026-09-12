// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_attendance_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentAttendanceListControllerHash() =>
    r'5c7ed98166c69748c49d124f539a2d8a24b22b88';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$StudentAttendanceListController
    extends BuildlessAutoDisposeAsyncNotifier<List<StudentAttendanceRecord>> {
  late final String? classId;
  late final DateTime? date;
  late final String? lectureId;
  late final String? studentId;
  late final String? status;

  FutureOr<List<StudentAttendanceRecord>> build({
    String? classId,
    DateTime? date,
    String? lectureId,
    String? studentId,
    String? status,
  });
}

/// See also [StudentAttendanceListController].
@ProviderFor(StudentAttendanceListController)
const studentAttendanceListControllerProvider =
    StudentAttendanceListControllerFamily();

/// See also [StudentAttendanceListController].
class StudentAttendanceListControllerFamily
    extends Family<AsyncValue<List<StudentAttendanceRecord>>> {
  /// See also [StudentAttendanceListController].
  const StudentAttendanceListControllerFamily();

  /// See also [StudentAttendanceListController].
  StudentAttendanceListControllerProvider call({
    String? classId,
    DateTime? date,
    String? lectureId,
    String? studentId,
    String? status,
  }) {
    return StudentAttendanceListControllerProvider(
      classId: classId,
      date: date,
      lectureId: lectureId,
      studentId: studentId,
      status: status,
    );
  }

  @override
  StudentAttendanceListControllerProvider getProviderOverride(
    covariant StudentAttendanceListControllerProvider provider,
  ) {
    return call(
      classId: provider.classId,
      date: provider.date,
      lectureId: provider.lectureId,
      studentId: provider.studentId,
      status: provider.status,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentAttendanceListControllerProvider';
}

/// See also [StudentAttendanceListController].
class StudentAttendanceListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          StudentAttendanceListController,
          List<StudentAttendanceRecord>
        > {
  /// See also [StudentAttendanceListController].
  StudentAttendanceListControllerProvider({
    String? classId,
    DateTime? date,
    String? lectureId,
    String? studentId,
    String? status,
  }) : this._internal(
         () => StudentAttendanceListController()
           ..classId = classId
           ..date = date
           ..lectureId = lectureId
           ..studentId = studentId
           ..status = status,
         from: studentAttendanceListControllerProvider,
         name: r'studentAttendanceListControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$studentAttendanceListControllerHash,
         dependencies: StudentAttendanceListControllerFamily._dependencies,
         allTransitiveDependencies:
             StudentAttendanceListControllerFamily._allTransitiveDependencies,
         classId: classId,
         date: date,
         lectureId: lectureId,
         studentId: studentId,
         status: status,
       );

  StudentAttendanceListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.date,
    required this.lectureId,
    required this.studentId,
    required this.status,
  }) : super.internal();

  final String? classId;
  final DateTime? date;
  final String? lectureId;
  final String? studentId;
  final String? status;

  @override
  FutureOr<List<StudentAttendanceRecord>> runNotifierBuild(
    covariant StudentAttendanceListController notifier,
  ) {
    return notifier.build(
      classId: classId,
      date: date,
      lectureId: lectureId,
      studentId: studentId,
      status: status,
    );
  }

  @override
  Override overrideWith(StudentAttendanceListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudentAttendanceListControllerProvider._internal(
        () => create()
          ..classId = classId
          ..date = date
          ..lectureId = lectureId
          ..studentId = studentId
          ..status = status,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        date: date,
        lectureId: lectureId,
        studentId: studentId,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    StudentAttendanceListController,
    List<StudentAttendanceRecord>
  >
  createElement() {
    return _StudentAttendanceListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentAttendanceListControllerProvider &&
        other.classId == classId &&
        other.date == date &&
        other.lectureId == lectureId &&
        other.studentId == studentId &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);
    hash = _SystemHash.combine(hash, lectureId.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentAttendanceListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<StudentAttendanceRecord>> {
  /// The parameter `classId` of this provider.
  String? get classId;

  /// The parameter `date` of this provider.
  DateTime? get date;

  /// The parameter `lectureId` of this provider.
  String? get lectureId;

  /// The parameter `studentId` of this provider.
  String? get studentId;

  /// The parameter `status` of this provider.
  String? get status;
}

class _StudentAttendanceListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          StudentAttendanceListController,
          List<StudentAttendanceRecord>
        >
    with StudentAttendanceListControllerRef {
  _StudentAttendanceListControllerProviderElement(super.provider);

  @override
  String? get classId =>
      (origin as StudentAttendanceListControllerProvider).classId;
  @override
  DateTime? get date =>
      (origin as StudentAttendanceListControllerProvider).date;
  @override
  String? get lectureId =>
      (origin as StudentAttendanceListControllerProvider).lectureId;
  @override
  String? get studentId =>
      (origin as StudentAttendanceListControllerProvider).studentId;
  @override
  String? get status =>
      (origin as StudentAttendanceListControllerProvider).status;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
