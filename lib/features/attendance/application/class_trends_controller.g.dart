// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_trends_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$classTrendsControllerHash() =>
    r'a0425d89c29d0084f39fb9e2ae4c4dd0831d9ac3';

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

abstract class _$ClassTrendsController
    extends BuildlessAutoDisposeAsyncNotifier<ClassTrendsResponse> {
  late final String classId;
  late final DateTime dateFrom;
  late final DateTime dateTo;

  FutureOr<ClassTrendsResponse> build({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  });
}

/// See also [ClassTrendsController].
@ProviderFor(ClassTrendsController)
const classTrendsControllerProvider = ClassTrendsControllerFamily();

/// See also [ClassTrendsController].
class ClassTrendsControllerFamily
    extends Family<AsyncValue<ClassTrendsResponse>> {
  /// See also [ClassTrendsController].
  const ClassTrendsControllerFamily();

  /// See also [ClassTrendsController].
  ClassTrendsControllerProvider call({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    return ClassTrendsControllerProvider(
      classId: classId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  ClassTrendsControllerProvider getProviderOverride(
    covariant ClassTrendsControllerProvider provider,
  ) {
    return call(
      classId: provider.classId,
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
  String? get name => r'classTrendsControllerProvider';
}

/// See also [ClassTrendsController].
class ClassTrendsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ClassTrendsController,
          ClassTrendsResponse
        > {
  /// See also [ClassTrendsController].
  ClassTrendsControllerProvider({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) : this._internal(
         () => ClassTrendsController()
           ..classId = classId
           ..dateFrom = dateFrom
           ..dateTo = dateTo,
         from: classTrendsControllerProvider,
         name: r'classTrendsControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$classTrendsControllerHash,
         dependencies: ClassTrendsControllerFamily._dependencies,
         allTransitiveDependencies:
             ClassTrendsControllerFamily._allTransitiveDependencies,
         classId: classId,
         dateFrom: dateFrom,
         dateTo: dateTo,
       );

  ClassTrendsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.dateFrom,
    required this.dateTo,
  }) : super.internal();

  final String classId;
  final DateTime dateFrom;
  final DateTime dateTo;

  @override
  FutureOr<ClassTrendsResponse> runNotifierBuild(
    covariant ClassTrendsController notifier,
  ) {
    return notifier.build(classId: classId, dateFrom: dateFrom, dateTo: dateTo);
  }

  @override
  Override overrideWith(ClassTrendsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ClassTrendsControllerProvider._internal(
        () => create()
          ..classId = classId
          ..dateFrom = dateFrom
          ..dateTo = dateTo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ClassTrendsController,
    ClassTrendsResponse
  >
  createElement() {
    return _ClassTrendsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassTrendsControllerProvider &&
        other.classId == classId &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, dateFrom.hashCode);
    hash = _SystemHash.combine(hash, dateTo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ClassTrendsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ClassTrendsResponse> {
  /// The parameter `classId` of this provider.
  String get classId;

  /// The parameter `dateFrom` of this provider.
  DateTime get dateFrom;

  /// The parameter `dateTo` of this provider.
  DateTime get dateTo;
}

class _ClassTrendsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ClassTrendsController,
          ClassTrendsResponse
        >
    with ClassTrendsControllerRef {
  _ClassTrendsControllerProviderElement(super.provider);

  @override
  String get classId => (origin as ClassTrendsControllerProvider).classId;
  @override
  DateTime get dateFrom => (origin as ClassTrendsControllerProvider).dateFrom;
  @override
  DateTime get dateTo => (origin as ClassTrendsControllerProvider).dateTo;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
