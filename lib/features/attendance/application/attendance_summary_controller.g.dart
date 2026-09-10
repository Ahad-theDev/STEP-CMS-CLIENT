// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attendanceSummaryControllerHash() =>
    r'b48978eb80354bb8ae8306961c28dcf88951cdc5';

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

abstract class _$AttendanceSummaryController
    extends
        BuildlessAutoDisposeAsyncNotifier<List<StudentAttendanceSummaryItem>> {
  late final String classId;
  late final DateTime dateFrom;
  late final DateTime dateTo;

  FutureOr<List<StudentAttendanceSummaryItem>> build({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  });
}

/// See also [AttendanceSummaryController].
@ProviderFor(AttendanceSummaryController)
const attendanceSummaryControllerProvider = AttendanceSummaryControllerFamily();

/// See also [AttendanceSummaryController].
class AttendanceSummaryControllerFamily
    extends Family<AsyncValue<List<StudentAttendanceSummaryItem>>> {
  /// See also [AttendanceSummaryController].
  const AttendanceSummaryControllerFamily();

  /// See also [AttendanceSummaryController].
  AttendanceSummaryControllerProvider call({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    return AttendanceSummaryControllerProvider(
      classId: classId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  AttendanceSummaryControllerProvider getProviderOverride(
    covariant AttendanceSummaryControllerProvider provider,
  ) {
    return call(
      classId: provider.classId,
      dateFrom: provider.dateFrom,
      dateTo: provider.dateTo,
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
  String? get name => r'attendanceSummaryControllerProvider';
}

/// See also [AttendanceSummaryController].
class AttendanceSummaryControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AttendanceSummaryController,
          List<StudentAttendanceSummaryItem>
        > {
  /// See also [AttendanceSummaryController].
  AttendanceSummaryControllerProvider({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) : this._internal(
         () => AttendanceSummaryController()
           ..classId = classId
           ..dateFrom = dateFrom
           ..dateTo = dateTo,
         from: attendanceSummaryControllerProvider,
         name: r'attendanceSummaryControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$attendanceSummaryControllerHash,
         dependencies: AttendanceSummaryControllerFamily._dependencies,
         allTransitiveDependencies:
             AttendanceSummaryControllerFamily._allTransitiveDependencies,
         classId: classId,
         dateFrom: dateFrom,
         dateTo: dateTo,
       );

  AttendanceSummaryControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.dateFrom,
    required this.dateTo,
  }) : super.internal();

  final String classId;
  final DateTime dateFrom;
  final DateTime dateTo;

  @override
  FutureOr<List<StudentAttendanceSummaryItem>> runNotifierBuild(
    covariant AttendanceSummaryController notifier,
  ) {
    return notifier.build(classId: classId, dateFrom: dateFrom, dateTo: dateTo);
  }

  @override
  Override overrideWith(AttendanceSummaryController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AttendanceSummaryControllerProvider._internal(
        () => create()
          ..classId = classId
          ..dateFrom = dateFrom
          ..dateTo = dateTo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    AttendanceSummaryController,
    List<StudentAttendanceSummaryItem>
  >
  createElement() {
    return _AttendanceSummaryControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceSummaryControllerProvider &&
        other.classId == classId &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, dateFrom.hashCode);
    hash = _SystemHash.combine(hash, dateTo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AttendanceSummaryControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<StudentAttendanceSummaryItem>> {
  /// The parameter `classId` of this provider.
  String get classId;

  /// The parameter `dateFrom` of this provider.
  DateTime get dateFrom;

  /// The parameter `dateTo` of this provider.
  DateTime get dateTo;
}

class _AttendanceSummaryControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AttendanceSummaryController,
          List<StudentAttendanceSummaryItem>
        >
    with AttendanceSummaryControllerRef {
  _AttendanceSummaryControllerProviderElement(super.provider);

  @override
  String get classId => (origin as AttendanceSummaryControllerProvider).classId;
  @override
  DateTime get dateFrom =>
      (origin as AttendanceSummaryControllerProvider).dateFrom;
  @override
  DateTime get dateTo => (origin as AttendanceSummaryControllerProvider).dateTo;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
