// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_lectures_for_class_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allLecturesForClassControllerHash() =>
    r'ad6213f169d4ff714e5b587595a5b382dc91a00b';

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

abstract class _$AllLecturesForClassController
    extends BuildlessAutoDisposeAsyncNotifier<List<Lecture>> {
  late final String classId;

  FutureOr<List<Lecture>> build({required String classId});
}

/// See also [AllLecturesForClassController].
@ProviderFor(AllLecturesForClassController)
const allLecturesForClassControllerProvider =
    AllLecturesForClassControllerFamily();

/// See also [AllLecturesForClassController].
class AllLecturesForClassControllerFamily
    extends Family<AsyncValue<List<Lecture>>> {
  /// See also [AllLecturesForClassController].
  const AllLecturesForClassControllerFamily();

  /// See also [AllLecturesForClassController].
  AllLecturesForClassControllerProvider call({required String classId}) {
    return AllLecturesForClassControllerProvider(classId: classId);
  }

  @override
  AllLecturesForClassControllerProvider getProviderOverride(
    covariant AllLecturesForClassControllerProvider provider,
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
  String? get name => r'allLecturesForClassControllerProvider';
}

/// See also [AllLecturesForClassController].
class AllLecturesForClassControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AllLecturesForClassController,
          List<Lecture>
        > {
  /// See also [AllLecturesForClassController].
  AllLecturesForClassControllerProvider({required String classId})
    : this._internal(
        () => AllLecturesForClassController()..classId = classId,
        from: allLecturesForClassControllerProvider,
        name: r'allLecturesForClassControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allLecturesForClassControllerHash,
        dependencies: AllLecturesForClassControllerFamily._dependencies,
        allTransitiveDependencies:
            AllLecturesForClassControllerFamily._allTransitiveDependencies,
        classId: classId,
      );

  AllLecturesForClassControllerProvider._internal(
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
  FutureOr<List<Lecture>> runNotifierBuild(
    covariant AllLecturesForClassController notifier,
  ) {
    return notifier.build(classId: classId);
  }

  @override
  Override overrideWith(AllLecturesForClassController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AllLecturesForClassControllerProvider._internal(
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
    AllLecturesForClassController,
    List<Lecture>
  >
  createElement() {
    return _AllLecturesForClassControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllLecturesForClassControllerProvider &&
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
mixin AllLecturesForClassControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Lecture>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _AllLecturesForClassControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AllLecturesForClassController,
          List<Lecture>
        >
    with AllLecturesForClassControllerRef {
  _AllLecturesForClassControllerProviderElement(super.provider);

  @override
  String get classId =>
      (origin as AllLecturesForClassControllerProvider).classId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
