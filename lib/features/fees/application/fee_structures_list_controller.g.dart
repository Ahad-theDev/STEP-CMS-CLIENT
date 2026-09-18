// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_structures_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feeStructuresListControllerHash() =>
    r'e9a3041b0d4aa20145b88b64d938151d7dff9f75';

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

abstract class _$FeeStructuresListController
    extends BuildlessAutoDisposeAsyncNotifier<List<FeeStructure>> {
  late final String? classId;
  late final String? academicYear;

  FutureOr<List<FeeStructure>> build({String? classId, String? academicYear});
}

/// See also [FeeStructuresListController].
@ProviderFor(FeeStructuresListController)
const feeStructuresListControllerProvider = FeeStructuresListControllerFamily();

/// See also [FeeStructuresListController].
class FeeStructuresListControllerFamily
    extends Family<AsyncValue<List<FeeStructure>>> {
  /// See also [FeeStructuresListController].
  const FeeStructuresListControllerFamily();

  /// See also [FeeStructuresListController].
  FeeStructuresListControllerProvider call({
    String? classId,
    String? academicYear,
  }) {
    return FeeStructuresListControllerProvider(
      classId: classId,
      academicYear: academicYear,
    );
  }

  @override
  FeeStructuresListControllerProvider getProviderOverride(
    covariant FeeStructuresListControllerProvider provider,
  ) {
    return call(classId: provider.classId, academicYear: provider.academicYear);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feeStructuresListControllerProvider';
}

/// See also [FeeStructuresListController].
class FeeStructuresListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          FeeStructuresListController,
          List<FeeStructure>
        > {
  /// See also [FeeStructuresListController].
  FeeStructuresListControllerProvider({String? classId, String? academicYear})
    : this._internal(
        () => FeeStructuresListController()
          ..classId = classId
          ..academicYear = academicYear,
        from: feeStructuresListControllerProvider,
        name: r'feeStructuresListControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feeStructuresListControllerHash,
        dependencies: FeeStructuresListControllerFamily._dependencies,
        allTransitiveDependencies:
            FeeStructuresListControllerFamily._allTransitiveDependencies,
        classId: classId,
        academicYear: academicYear,
      );

  FeeStructuresListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.academicYear,
  }) : super.internal();

  final String? classId;
  final String? academicYear;

  @override
  FutureOr<List<FeeStructure>> runNotifierBuild(
    covariant FeeStructuresListController notifier,
  ) {
    return notifier.build(classId: classId, academicYear: academicYear);
  }

  @override
  Override overrideWith(FeeStructuresListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeeStructuresListControllerProvider._internal(
        () => create()
          ..classId = classId
          ..academicYear = academicYear,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        academicYear: academicYear,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    FeeStructuresListController,
    List<FeeStructure>
  >
  createElement() {
    return _FeeStructuresListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeeStructuresListControllerProvider &&
        other.classId == classId &&
        other.academicYear == academicYear;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, academicYear.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeeStructuresListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<FeeStructure>> {
  /// The parameter `classId` of this provider.
  String? get classId;

  /// The parameter `academicYear` of this provider.
  String? get academicYear;
}

class _FeeStructuresListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          FeeStructuresListController,
          List<FeeStructure>
        >
    with FeeStructuresListControllerRef {
  _FeeStructuresListControllerProviderElement(super.provider);

  @override
  String? get classId =>
      (origin as FeeStructuresListControllerProvider).classId;
  @override
  String? get academicYear =>
      (origin as FeeStructuresListControllerProvider).academicYear;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
