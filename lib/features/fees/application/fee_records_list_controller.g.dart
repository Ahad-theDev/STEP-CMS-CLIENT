// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_records_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feeRecordsListControllerHash() =>
    r'a5873f8d4a143e819c1b1ebd4754c0a5cda9861d';

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

abstract class _$FeeRecordsListController
    extends BuildlessAutoDisposeAsyncNotifier<List<FeeRecord>> {
  late final String? studentId;
  late final int? month;
  late final int? year;
  late final String? status;

  FutureOr<List<FeeRecord>> build({
    String? studentId,
    int? month,
    int? year,
    String? status,
  });
}

/// See also [FeeRecordsListController].
@ProviderFor(FeeRecordsListController)
const feeRecordsListControllerProvider = FeeRecordsListControllerFamily();

/// See also [FeeRecordsListController].
class FeeRecordsListControllerFamily
    extends Family<AsyncValue<List<FeeRecord>>> {
  /// See also [FeeRecordsListController].
  const FeeRecordsListControllerFamily();

  /// See also [FeeRecordsListController].
  FeeRecordsListControllerProvider call({
    String? studentId,
    int? month,
    int? year,
    String? status,
  }) {
    return FeeRecordsListControllerProvider(
      studentId: studentId,
      month: month,
      year: year,
      status: status,
    );
  }

  @override
  FeeRecordsListControllerProvider getProviderOverride(
    covariant FeeRecordsListControllerProvider provider,
  ) {
    return call(
      studentId: provider.studentId,
      month: provider.month,
      year: provider.year,
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
  String? get name => r'feeRecordsListControllerProvider';
}

/// See also [FeeRecordsListController].
class FeeRecordsListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          FeeRecordsListController,
          List<FeeRecord>
        > {
  /// See also [FeeRecordsListController].
  FeeRecordsListControllerProvider({
    String? studentId,
    int? month,
    int? year,
    String? status,
  }) : this._internal(
         () => FeeRecordsListController()
           ..studentId = studentId
           ..month = month
           ..year = year
           ..status = status,
         from: feeRecordsListControllerProvider,
         name: r'feeRecordsListControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$feeRecordsListControllerHash,
         dependencies: FeeRecordsListControllerFamily._dependencies,
         allTransitiveDependencies:
             FeeRecordsListControllerFamily._allTransitiveDependencies,
         studentId: studentId,
         month: month,
         year: year,
         status: status,
       );

  FeeRecordsListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.month,
    required this.year,
    required this.status,
  }) : super.internal();

  final String? studentId;
  final int? month;
  final int? year;
  final String? status;

  @override
  FutureOr<List<FeeRecord>> runNotifierBuild(
    covariant FeeRecordsListController notifier,
  ) {
    return notifier.build(
      studentId: studentId,
      month: month,
      year: year,
      status: status,
    );
  }

  @override
  Override overrideWith(FeeRecordsListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeeRecordsListControllerProvider._internal(
        () => create()
          ..studentId = studentId
          ..month = month
          ..year = year
          ..status = status,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        month: month,
        year: year,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    FeeRecordsListController,
    List<FeeRecord>
  >
  createElement() {
    return _FeeRecordsListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeeRecordsListControllerProvider &&
        other.studentId == studentId &&
        other.month == month &&
        other.year == year &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeeRecordsListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<FeeRecord>> {
  /// The parameter `studentId` of this provider.
  String? get studentId;

  /// The parameter `month` of this provider.
  int? get month;

  /// The parameter `year` of this provider.
  int? get year;

  /// The parameter `status` of this provider.
  String? get status;
}

class _FeeRecordsListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          FeeRecordsListController,
          List<FeeRecord>
        >
    with FeeRecordsListControllerRef {
  _FeeRecordsListControllerProviderElement(super.provider);

  @override
  String? get studentId =>
      (origin as FeeRecordsListControllerProvider).studentId;
  @override
  int? get month => (origin as FeeRecordsListControllerProvider).month;
  @override
  int? get year => (origin as FeeRecordsListControllerProvider).year;
  @override
  String? get status => (origin as FeeRecordsListControllerProvider).status;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
