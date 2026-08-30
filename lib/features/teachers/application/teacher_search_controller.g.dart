// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherSearchControllerHash() =>
    r'48de37d7a642791f7a4c6bfc60a39968e9c7ebc7';

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

abstract class _$TeacherSearchController
    extends BuildlessAutoDisposeAsyncNotifier<List<Teacher>> {
  late final String? department;
  late final String? subjectId;
  late final int page;

  FutureOr<List<Teacher>> build({
    String? department,
    String? subjectId,
    int page = 1,
  });
}

/// See also [TeacherSearchController].
@ProviderFor(TeacherSearchController)
const teacherSearchControllerProvider = TeacherSearchControllerFamily();

/// See also [TeacherSearchController].
class TeacherSearchControllerFamily extends Family<AsyncValue<List<Teacher>>> {
  /// See also [TeacherSearchController].
  const TeacherSearchControllerFamily();

  /// See also [TeacherSearchController].
  TeacherSearchControllerProvider call({
    String? department,
    String? subjectId,
    int page = 1,
  }) {
    return TeacherSearchControllerProvider(
      department: department,
      subjectId: subjectId,
      page: page,
    );
  }

  @override
  TeacherSearchControllerProvider getProviderOverride(
    covariant TeacherSearchControllerProvider provider,
  ) {
    return call(
      department: provider.department,
      subjectId: provider.subjectId,
      page: provider.page,
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
  String? get name => r'teacherSearchControllerProvider';
}

/// See also [TeacherSearchController].
class TeacherSearchControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          TeacherSearchController,
          List<Teacher>
        > {
  /// See also [TeacherSearchController].
  TeacherSearchControllerProvider({
    String? department,
    String? subjectId,
    int page = 1,
  }) : this._internal(
         () => TeacherSearchController()
           ..department = department
           ..subjectId = subjectId
           ..page = page,
         from: teacherSearchControllerProvider,
         name: r'teacherSearchControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$teacherSearchControllerHash,
         dependencies: TeacherSearchControllerFamily._dependencies,
         allTransitiveDependencies:
             TeacherSearchControllerFamily._allTransitiveDependencies,
         department: department,
         subjectId: subjectId,
         page: page,
       );

  TeacherSearchControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.department,
    required this.subjectId,
    required this.page,
  }) : super.internal();

  final String? department;
  final String? subjectId;
  final int page;

  @override
  FutureOr<List<Teacher>> runNotifierBuild(
    covariant TeacherSearchController notifier,
  ) {
    return notifier.build(
      department: department,
      subjectId: subjectId,
      page: page,
    );
  }

  @override
  Override overrideWith(TeacherSearchController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TeacherSearchControllerProvider._internal(
        () => create()
          ..department = department
          ..subjectId = subjectId
          ..page = page,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        department: department,
        subjectId: subjectId,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    TeacherSearchController,
    List<Teacher>
  >
  createElement() {
    return _TeacherSearchControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherSearchControllerProvider &&
        other.department == department &&
        other.subjectId == subjectId &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, department.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeacherSearchControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Teacher>> {
  /// The parameter `department` of this provider.
  String? get department;

  /// The parameter `subjectId` of this provider.
  String? get subjectId;

  /// The parameter `page` of this provider.
  int get page;
}

class _TeacherSearchControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          TeacherSearchController,
          List<Teacher>
        >
    with TeacherSearchControllerRef {
  _TeacherSearchControllerProviderElement(super.provider);

  @override
  String? get department =>
      (origin as TeacherSearchControllerProvider).department;
  @override
  String? get subjectId =>
      (origin as TeacherSearchControllerProvider).subjectId;
  @override
  int get page => (origin as TeacherSearchControllerProvider).page;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
