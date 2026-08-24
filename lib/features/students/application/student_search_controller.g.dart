// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentSearchControllerHash() =>
    r'6b03b521d7048d932d7197033dec282133df2b34';

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

abstract class _$StudentSearchController
    extends BuildlessAutoDisposeAsyncNotifier<List<Student>> {
  late final String classId;
  late final int page;

  FutureOr<List<Student>> build({required String classId, int page = 1});
}

/// See also [StudentSearchController].
@ProviderFor(StudentSearchController)
const studentSearchControllerProvider = StudentSearchControllerFamily();

/// See also [StudentSearchController].
class StudentSearchControllerFamily extends Family<AsyncValue<List<Student>>> {
  /// See also [StudentSearchController].
  const StudentSearchControllerFamily();

  /// See also [StudentSearchController].
  StudentSearchControllerProvider call({
    required String classId,
    int page = 1,
  }) {
    return StudentSearchControllerProvider(classId: classId, page: page);
  }

  @override
  StudentSearchControllerProvider getProviderOverride(
    covariant StudentSearchControllerProvider provider,
  ) {
    return call(classId: provider.classId, page: provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentSearchControllerProvider';
}

/// See also [StudentSearchController].
class StudentSearchControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          StudentSearchController,
          List<Student>
        > {
  /// See also [StudentSearchController].
  StudentSearchControllerProvider({required String classId, int page = 1})
    : this._internal(
        () => StudentSearchController()
          ..classId = classId
          ..page = page,
        from: studentSearchControllerProvider,
        name: r'studentSearchControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentSearchControllerHash,
        dependencies: StudentSearchControllerFamily._dependencies,
        allTransitiveDependencies:
            StudentSearchControllerFamily._allTransitiveDependencies,
        classId: classId,
        page: page,
      );

  StudentSearchControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.page,
  }) : super.internal();

  final String classId;
  final int page;

  @override
  FutureOr<List<Student>> runNotifierBuild(
    covariant StudentSearchController notifier,
  ) {
    return notifier.build(classId: classId, page: page);
  }

  @override
  Override overrideWith(StudentSearchController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudentSearchControllerProvider._internal(
        () => create()
          ..classId = classId
          ..page = page,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    StudentSearchController,
    List<Student>
  >
  createElement() {
    return _StudentSearchControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentSearchControllerProvider &&
        other.classId == classId &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentSearchControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Student>> {
  /// The parameter `classId` of this provider.
  String get classId;

  /// The parameter `page` of this provider.
  int get page;
}

class _StudentSearchControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          StudentSearchController,
          List<Student>
        >
    with StudentSearchControllerRef {
  _StudentSearchControllerProviderElement(super.provider);

  @override
  String get classId => (origin as StudentSearchControllerProvider).classId;
  @override
  int get page => (origin as StudentSearchControllerProvider).page;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
