// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$classesListControllerHash() =>
    r'8041ccd358f81c9e7e11c56d14c02f88167c201c';

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

abstract class _$ClassesListController
    extends BuildlessAutoDisposeAsyncNotifier<List<SchoolClass>> {
  late final int page;

  FutureOr<List<SchoolClass>> build({int page = 1});
}

/// See also [ClassesListController].
@ProviderFor(ClassesListController)
const classesListControllerProvider = ClassesListControllerFamily();

/// See also [ClassesListController].
class ClassesListControllerFamily
    extends Family<AsyncValue<List<SchoolClass>>> {
  /// See also [ClassesListController].
  const ClassesListControllerFamily();

  /// See also [ClassesListController].
  ClassesListControllerProvider call({int page = 1}) {
    return ClassesListControllerProvider(page: page);
  }

  @override
  ClassesListControllerProvider getProviderOverride(
    covariant ClassesListControllerProvider provider,
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
  String? get name => r'classesListControllerProvider';
}

/// See also [ClassesListController].
class ClassesListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ClassesListController,
          List<SchoolClass>
        > {
  /// See also [ClassesListController].
  ClassesListControllerProvider({int page = 1})
    : this._internal(
        () => ClassesListController()..page = page,
        from: classesListControllerProvider,
        name: r'classesListControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$classesListControllerHash,
        dependencies: ClassesListControllerFamily._dependencies,
        allTransitiveDependencies:
            ClassesListControllerFamily._allTransitiveDependencies,
        page: page,
      );

  ClassesListControllerProvider._internal(
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
  FutureOr<List<SchoolClass>> runNotifierBuild(
    covariant ClassesListController notifier,
  ) {
    return notifier.build(page: page);
  }

  @override
  Override overrideWith(ClassesListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ClassesListControllerProvider._internal(
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
    ClassesListController,
    List<SchoolClass>
  >
  createElement() {
    return _ClassesListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassesListControllerProvider && other.page == page;
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
mixin ClassesListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<SchoolClass>> {
  /// The parameter `page` of this provider.
  int get page;
}

class _ClassesListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ClassesListController,
          List<SchoolClass>
        >
    with ClassesListControllerRef {
  _ClassesListControllerProviderElement(super.provider);

  @override
  int get page => (origin as ClassesListControllerProvider).page;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
