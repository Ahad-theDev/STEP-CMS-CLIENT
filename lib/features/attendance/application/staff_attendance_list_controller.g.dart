// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_attendance_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$staffAttendanceListControllerHash() =>
    r'3da9a9e5477a53471bb44ac8b125cb181d2457f9';

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

abstract class _$StaffAttendanceListController
    extends BuildlessAutoDisposeAsyncNotifier<List<StaffAttendance>> {
  late final DateTime? date;
  late final String? personId;

  FutureOr<List<StaffAttendance>> build({DateTime? date, String? personId});
}

/// See also [StaffAttendanceListController].
@ProviderFor(StaffAttendanceListController)
const staffAttendanceListControllerProvider =
    StaffAttendanceListControllerFamily();

/// See also [StaffAttendanceListController].
class StaffAttendanceListControllerFamily
    extends Family<AsyncValue<List<StaffAttendance>>> {
  /// See also [StaffAttendanceListController].
  const StaffAttendanceListControllerFamily();

  /// See also [StaffAttendanceListController].
  StaffAttendanceListControllerProvider call({
    DateTime? date,
    String? personId,
  }) {
    return StaffAttendanceListControllerProvider(
      date: date,
      personId: personId,
    );
  }

  @override
  StaffAttendanceListControllerProvider getProviderOverride(
    covariant StaffAttendanceListControllerProvider provider,
  ) {
    return call(date: provider.date, personId: provider.personId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'staffAttendanceListControllerProvider';
}

/// See also [StaffAttendanceListController].
class StaffAttendanceListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          StaffAttendanceListController,
          List<StaffAttendance>
        > {
  /// See also [StaffAttendanceListController].
  StaffAttendanceListControllerProvider({DateTime? date, String? personId})
    : this._internal(
        () => StaffAttendanceListController()
          ..date = date
          ..personId = personId,
        from: staffAttendanceListControllerProvider,
        name: r'staffAttendanceListControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$staffAttendanceListControllerHash,
        dependencies: StaffAttendanceListControllerFamily._dependencies,
        allTransitiveDependencies:
            StaffAttendanceListControllerFamily._allTransitiveDependencies,
        date: date,
        personId: personId,
      );

  StaffAttendanceListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
    required this.personId,
  }) : super.internal();

  final DateTime? date;
  final String? personId;

  @override
  FutureOr<List<StaffAttendance>> runNotifierBuild(
    covariant StaffAttendanceListController notifier,
  ) {
    return notifier.build(date: date, personId: personId);
  }

  @override
  Override overrideWith(StaffAttendanceListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StaffAttendanceListControllerProvider._internal(
        () => create()
          ..date = date
          ..personId = personId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
        personId: personId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    StaffAttendanceListController,
    List<StaffAttendance>
  >
  createElement() {
    return _StaffAttendanceListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StaffAttendanceListControllerProvider &&
        other.date == date &&
        other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StaffAttendanceListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<StaffAttendance>> {
  /// The parameter `date` of this provider.
  DateTime? get date;

  /// The parameter `personId` of this provider.
  String? get personId;
}

class _StaffAttendanceListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          StaffAttendanceListController,
          List<StaffAttendance>
        >
    with StaffAttendanceListControllerRef {
  _StaffAttendanceListControllerProviderElement(super.provider);

  @override
  DateTime? get date => (origin as StaffAttendanceListControllerProvider).date;
  @override
  String? get personId =>
      (origin as StaffAttendanceListControllerProvider).personId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
