// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_students_for_class_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allStudentsForClassControllerHash() =>
    r'88343ad475e19814739a260c08cd2cfc5d1a2783';

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

abstract class _$AllStudentsForClassController
    extends BuildlessAutoDisposeAsyncNotifier<List<Student>> {
  late final String classId;

  FutureOr<List<Student>> build({required String classId});
}

/// See also [AllStudentsForClassController].
@ProviderFor(AllStudentsForClassController)
const allStudentsForClassControllerProvider =
    AllStudentsForClassControllerFamily();

/// See also [AllStudentsForClassController].
class AllStudentsForClassControllerFamily
    extends Family<AsyncValue<List<Student>>> {
  /// See also [AllStudentsForClassController].
  const AllStudentsForClassControllerFamily();

  /// See also [AllStudentsForClassController].
  AllStudentsForClassControllerProvider call({required String classId}) {
    return AllStudentsForClassControllerProvider(classId: classId);
  }

  @override
  AllStudentsForClassControllerProvider getProviderOverride(
    covariant AllStudentsForClassControllerProvider provider,
  ) {
    return call(classId: provider.classId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allStudentsForClassControllerProvider';
}

/// See also [AllStudentsForClassController].
class AllStudentsForClassControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AllStudentsForClassController,
          List<Student>
        > {
  /// See also [AllStudentsForClassController].
  AllStudentsForClassControllerProvider({required String classId})
    : this._internal(
        () => AllStudentsForClassController()..classId = classId,
        from: allStudentsForClassControllerProvider,
        name: r'allStudentsForClassControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allStudentsForClassControllerHash,
        dependencies: AllStudentsForClassControllerFamily._dependencies,
        allTransitiveDependencies:
            AllStudentsForClassControllerFamily._allTransitiveDependencies,
        classId: classId,
      );

  AllStudentsForClassControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final String classId;

  @override
  FutureOr<List<Student>> runNotifierBuild(
    covariant AllStudentsForClassController notifier,
  ) {
    return notifier.build(classId: classId);
  }

  @override
  Override overrideWith(AllStudentsForClassController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AllStudentsForClassControllerProvider._internal(
        () => create()..classId = classId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    AllStudentsForClassController,
    List<Student>
  >
  createElement() {
    return _AllStudentsForClassControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllStudentsForClassControllerProvider &&
        other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllStudentsForClassControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Student>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _AllStudentsForClassControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AllStudentsForClassController,
          List<Student>
        >
    with AllStudentsForClassControllerRef {
  _AllStudentsForClassControllerProviderElement(super.provider);

  @override
  String get classId =>
      (origin as AllStudentsForClassControllerProvider).classId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
