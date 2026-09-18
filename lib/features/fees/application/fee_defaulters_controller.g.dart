// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_defaulters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feeDefaultersControllerHash() =>
    r'49ab90556615e01148aa002843c1da19d399c3fd';

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

abstract class _$FeeDefaultersController
    extends BuildlessAutoDisposeAsyncNotifier<FeeDefaultersResponse> {
  late final String? classId;
  late final int? month;
  late final int? year;

  FutureOr<FeeDefaultersResponse> build({
    String? classId,
    int? month,
    int? year,
  });
}

/// See also [FeeDefaultersController].
@ProviderFor(FeeDefaultersController)
const feeDefaultersControllerProvider = FeeDefaultersControllerFamily();

/// See also [FeeDefaultersController].
class FeeDefaultersControllerFamily
    extends Family<AsyncValue<FeeDefaultersResponse>> {
  /// See also [FeeDefaultersController].
  const FeeDefaultersControllerFamily();

  /// See also [FeeDefaultersController].
  FeeDefaultersControllerProvider call({
    String? classId,
    int? month,
    int? year,
  }) {
    return FeeDefaultersControllerProvider(
      classId: classId,
      month: month,
      year: year,
    );
  }

  @override
  FeeDefaultersControllerProvider getProviderOverride(
    covariant FeeDefaultersControllerProvider provider,
  ) {
    return call(
      classId: provider.classId,
      month: provider.month,
      year: provider.year,
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
  String? get name => r'feeDefaultersControllerProvider';
}

/// See also [FeeDefaultersController].
class FeeDefaultersControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          FeeDefaultersController,
          FeeDefaultersResponse
        > {
  /// See also [FeeDefaultersController].
  FeeDefaultersControllerProvider({String? classId, int? month, int? year})
    : this._internal(
        () => FeeDefaultersController()
          ..classId = classId
          ..month = month
          ..year = year,
        from: feeDefaultersControllerProvider,
        name: r'feeDefaultersControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feeDefaultersControllerHash,
        dependencies: FeeDefaultersControllerFamily._dependencies,
        allTransitiveDependencies:
            FeeDefaultersControllerFamily._allTransitiveDependencies,
        classId: classId,
        month: month,
        year: year,
      );

  FeeDefaultersControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.month,
    required this.year,
  }) : super.internal();

  final String? classId;
  final int? month;
  final int? year;

  @override
  FutureOr<FeeDefaultersResponse> runNotifierBuild(
    covariant FeeDefaultersController notifier,
  ) {
    return notifier.build(classId: classId, month: month, year: year);
  }

  @override
  Override overrideWith(FeeDefaultersController Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeeDefaultersControllerProvider._internal(
        () => create()
          ..classId = classId
          ..month = month
          ..year = year,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        month: month,
        year: year,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    FeeDefaultersController,
    FeeDefaultersResponse
  >
  createElement() {
    return _FeeDefaultersControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeeDefaultersControllerProvider &&
        other.classId == classId &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeeDefaultersControllerRef
    on AutoDisposeAsyncNotifierProviderRef<FeeDefaultersResponse> {
  /// The parameter `classId` of this provider.
  String? get classId;

  /// The parameter `month` of this provider.
  int? get month;

  /// The parameter `year` of this provider.
  int? get year;
}

class _FeeDefaultersControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          FeeDefaultersController,
          FeeDefaultersResponse
        >
    with FeeDefaultersControllerRef {
  _FeeDefaultersControllerProviderElement(super.provider);

  @override
  String? get classId => (origin as FeeDefaultersControllerProvider).classId;
  @override
  int? get month => (origin as FeeDefaultersControllerProvider).month;
  @override
  int? get year => (origin as FeeDefaultersControllerProvider).year;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
