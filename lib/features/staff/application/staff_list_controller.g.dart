// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$staffListControllerHash() =>
    r'85ac970e045922a67fdb08796350361ee46a747b';

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

abstract class _$StaffListController
    extends BuildlessAutoDisposeAsyncNotifier<List<StaffMember>> {
  late final int page;

  FutureOr<List<StaffMember>> build({int page = 1});
}

/// See also [StaffListController].
@ProviderFor(StaffListController)
const staffListControllerProvider = StaffListControllerFamily();

/// See also [StaffListController].
class StaffListControllerFamily extends Family<AsyncValue<List<StaffMember>>> {
  /// See also [StaffListController].
  const StaffListControllerFamily();

  /// See also [StaffListController].
  StaffListControllerProvider call({int page = 1}) {
    return StaffListControllerProvider(page: page);
  }

  @override
  StaffListControllerProvider getProviderOverride(
    covariant StaffListControllerProvider provider,
  ) {
    return call(page: provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'staffListControllerProvider';
}

/// See also [StaffListController].
class StaffListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          StaffListController,
          List<StaffMember>
        > {
  /// See also [StaffListController].
  StaffListControllerProvider({int page = 1})
    : this._internal(
        () => StaffListController()..page = page,
        from: staffListControllerProvider,
        name: r'staffListControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$staffListControllerHash,
        dependencies: StaffListControllerFamily._dependencies,
        allTransitiveDependencies:
            StaffListControllerFamily._allTransitiveDependencies,
        page: page,
      );

  StaffListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
  }) : super.internal();

  final int page;

  @override
  FutureOr<List<StaffMember>> runNotifierBuild(
    covariant StaffListController notifier,
  ) {
    return notifier.build(page: page);
  }

  @override
  Override overrideWith(StaffListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StaffListControllerProvider._internal(
        () => create()..page = page,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    StaffListController,
    List<StaffMember>
  >
  createElement() {
    return _StaffListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StaffListControllerProvider && other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StaffListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<StaffMember>> {
  /// The parameter `page` of this provider.
  int get page;
}

class _StaffListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          StaffListController,
          List<StaffMember>
        >
    with StaffListControllerRef {
  _StaffListControllerProviderElement(super.provider);

  @override
  int get page => (origin as StaffListControllerProvider).page;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
