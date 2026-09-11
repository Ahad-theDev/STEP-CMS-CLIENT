// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_trends_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherTrendsControllerHash() =>
    r'cdebe9345d3941e7033d685952d16c4de2e1904f';

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

abstract class _$TeacherTrendsController
    extends BuildlessAutoDisposeAsyncNotifier<TeacherTrendsResponse> {
  late final String teacherId;
  late final DateTime dateFrom;
  late final DateTime dateTo;

  FutureOr<TeacherTrendsResponse> build({
    required String teacherId,
    required DateTime dateFrom,
    required DateTime dateTo,
  });
}

/// See also [TeacherTrendsController].
@ProviderFor(TeacherTrendsController)
const teacherTrendsControllerProvider = TeacherTrendsControllerFamily();

/// See also [TeacherTrendsController].
class TeacherTrendsControllerFamily
    extends Family<AsyncValue<TeacherTrendsResponse>> {
  /// See also [TeacherTrendsController].
  const TeacherTrendsControllerFamily();

  /// See also [TeacherTrendsController].
  TeacherTrendsControllerProvider call({
    required String teacherId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    return TeacherTrendsControllerProvider(
      teacherId: teacherId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  TeacherTrendsControllerProvider getProviderOverride(
    covariant TeacherTrendsControllerProvider provider,
  ) {
    return call(
      teacherId: provider.teacherId,
      dateFrom: provider.dateFrom,
      dateTo: provider.dateTo,
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
  String? get name => r'teacherTrendsControllerProvider';
}

/// See also [TeacherTrendsController].
class TeacherTrendsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          TeacherTrendsController,
          TeacherTrendsResponse
        > {
  /// See also [TeacherTrendsController].
  TeacherTrendsControllerProvider({
    required String teacherId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) : this._internal(
         () => TeacherTrendsController()
           ..teacherId = teacherId
           ..dateFrom = dateFrom
           ..dateTo = dateTo,
         from: teacherTrendsControllerProvider,
         name: r'teacherTrendsControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$teacherTrendsControllerHash,
         dependencies: TeacherTrendsControllerFamily._dependencies,
         allTransitiveDependencies:
             TeacherTrendsControllerFamily._allTransitiveDependencies,
         teacherId: teacherId,
         dateFrom: dateFrom,
         dateTo: dateTo,
       );

  TeacherTrendsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.teacherId,
    required this.dateFrom,
    required this.dateTo,
  }) : super.internal();

  final String teacherId;
  final DateTime dateFrom;
  final DateTime dateTo;

  @override
  FutureOr<TeacherTrendsResponse> runNotifierBuild(
    covariant TeacherTrendsController notifier,
  ) {
    return notifier.build(
      teacherId: teacherId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  Override overrideWith(TeacherTrendsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TeacherTrendsControllerProvider._internal(
        () => create()
          ..teacherId = teacherId
          ..dateFrom = dateFrom
          ..dateTo = dateTo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        teacherId: teacherId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    TeacherTrendsController,
    TeacherTrendsResponse
  >
  createElement() {
    return _TeacherTrendsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherTrendsControllerProvider &&
        other.teacherId == teacherId &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, teacherId.hashCode);
    hash = _SystemHash.combine(hash, dateFrom.hashCode);
    hash = _SystemHash.combine(hash, dateTo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeacherTrendsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<TeacherTrendsResponse> {
  /// The parameter `teacherId` of this provider.
  String get teacherId;

  /// The parameter `dateFrom` of this provider.
  DateTime get dateFrom;

  /// The parameter `dateTo` of this provider.
  DateTime get dateTo;
}

class _TeacherTrendsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          TeacherTrendsController,
          TeacherTrendsResponse
        >
    with TeacherTrendsControllerRef {
  _TeacherTrendsControllerProviderElement(super.provider);

  @override
  String get teacherId => (origin as TeacherTrendsControllerProvider).teacherId;
  @override
  DateTime get dateFrom => (origin as TeacherTrendsControllerProvider).dateFrom;
  @override
  DateTime get dateTo => (origin as TeacherTrendsControllerProvider).dateTo;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
