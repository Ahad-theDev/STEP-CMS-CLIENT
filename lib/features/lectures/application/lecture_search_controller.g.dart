// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecture_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lectureSearchControllerHash() =>
    r'4931c71b89fe74fd8850cbbab0acce95a478899e';

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

abstract class _$LectureSearchController
    extends BuildlessAutoDisposeAsyncNotifier<List<Lecture>> {
  late final String? classId;
  late final String? teacherId;
  late final String? dayOfWeek;
  late final int page;

  FutureOr<List<Lecture>> build({
    String? classId,
    String? teacherId,
    String? dayOfWeek,
    int page = 1,
  });
}

/// See also [LectureSearchController].
@ProviderFor(LectureSearchController)
const lectureSearchControllerProvider = LectureSearchControllerFamily();

/// See also [LectureSearchController].
class LectureSearchControllerFamily extends Family<AsyncValue<List<Lecture>>> {
  /// See also [LectureSearchController].
  const LectureSearchControllerFamily();

  /// See also [LectureSearchController].
  LectureSearchControllerProvider call({
    String? classId,
    String? teacherId,
    String? dayOfWeek,
    int page = 1,
  }) {
    return LectureSearchControllerProvider(
      classId: classId,
      teacherId: teacherId,
      dayOfWeek: dayOfWeek,
      page: page,
    );
  }

  @override
  LectureSearchControllerProvider getProviderOverride(
    covariant LectureSearchControllerProvider provider,
  ) {
    return call(
      classId: provider.classId,
      teacherId: provider.teacherId,
      dayOfWeek: provider.dayOfWeek,
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
  String? get name => r'lectureSearchControllerProvider';
}

/// See also [LectureSearchController].
class LectureSearchControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          LectureSearchController,
          List<Lecture>
        > {
  /// See also [LectureSearchController].
  LectureSearchControllerProvider({
    String? classId,
    String? teacherId,
    String? dayOfWeek,
    int page = 1,
  }) : this._internal(
         () => LectureSearchController()
           ..classId = classId
           ..teacherId = teacherId
           ..dayOfWeek = dayOfWeek
           ..page = page,
         from: lectureSearchControllerProvider,
         name: r'lectureSearchControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$lectureSearchControllerHash,
         dependencies: LectureSearchControllerFamily._dependencies,
         allTransitiveDependencies:
             LectureSearchControllerFamily._allTransitiveDependencies,
         classId: classId,
         teacherId: teacherId,
         dayOfWeek: dayOfWeek,
         page: page,
       );

  LectureSearchControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.teacherId,
    required this.dayOfWeek,
    required this.page,
  }) : super.internal();

  final String? classId;
  final String? teacherId;
  final String? dayOfWeek;
  final int page;

  @override
  FutureOr<List<Lecture>> runNotifierBuild(
    covariant LectureSearchController notifier,
  ) {
    return notifier.build(
      classId: classId,
      teacherId: teacherId,
      dayOfWeek: dayOfWeek,
      page: page,
    );
  }

  @override
  Override overrideWith(LectureSearchController Function() create) {
    return ProviderOverride(
      origin: this,
      override: LectureSearchControllerProvider._internal(
        () => create()
          ..classId = classId
          ..teacherId = teacherId
          ..dayOfWeek = dayOfWeek
          ..page = page,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        teacherId: teacherId,
        dayOfWeek: dayOfWeek,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    LectureSearchController,
    List<Lecture>
  >
  createElement() {
    return _LectureSearchControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LectureSearchControllerProvider &&
        other.classId == classId &&
        other.teacherId == teacherId &&
        other.dayOfWeek == dayOfWeek &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, teacherId.hashCode);
    hash = _SystemHash.combine(hash, dayOfWeek.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LectureSearchControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Lecture>> {
  /// The parameter `classId` of this provider.
  String? get classId;

  /// The parameter `teacherId` of this provider.
  String? get teacherId;

  /// The parameter `dayOfWeek` of this provider.
  String? get dayOfWeek;

  /// The parameter `page` of this provider.
  int get page;
}

class _LectureSearchControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          LectureSearchController,
          List<Lecture>
        >
    with LectureSearchControllerRef {
  _LectureSearchControllerProviderElement(super.provider);

  @override
  String? get classId => (origin as LectureSearchControllerProvider).classId;
  @override
  String? get teacherId =>
      (origin as LectureSearchControllerProvider).teacherId;
  @override
  String? get dayOfWeek =>
      (origin as LectureSearchControllerProvider).dayOfWeek;
  @override
  int get page => (origin as LectureSearchControllerProvider).page;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
