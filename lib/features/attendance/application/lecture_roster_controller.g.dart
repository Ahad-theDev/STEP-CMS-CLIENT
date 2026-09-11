// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecture_roster_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lectureRosterControllerHash() =>
    r'c42a22ab3daf219534bac6dbe1b76098ee9d1fd7';

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

abstract class _$LectureRosterController
    extends BuildlessAutoDisposeAsyncNotifier<LectureRoster> {
  late final String lectureId;
  late final DateTime date;

  FutureOr<LectureRoster> build({
    required String lectureId,
    required DateTime date,
  });
}

/// See also [LectureRosterController].
@ProviderFor(LectureRosterController)
const lectureRosterControllerProvider = LectureRosterControllerFamily();

/// See also [LectureRosterController].
class LectureRosterControllerFamily extends Family<AsyncValue<LectureRoster>> {
  /// See also [LectureRosterController].
  const LectureRosterControllerFamily();

  /// See also [LectureRosterController].
  LectureRosterControllerProvider call({
    required String lectureId,
    required DateTime date,
  }) {
    return LectureRosterControllerProvider(lectureId: lectureId, date: date);
  }

  @override
  LectureRosterControllerProvider getProviderOverride(
    covariant LectureRosterControllerProvider provider,
  ) {
    return call(lectureId: provider.lectureId, date: provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lectureRosterControllerProvider';
}

/// See also [LectureRosterController].
class LectureRosterControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          LectureRosterController,
          LectureRoster
        > {
  /// See also [LectureRosterController].
  LectureRosterControllerProvider({
    required String lectureId,
    required DateTime date,
  }) : this._internal(
         () => LectureRosterController()
           ..lectureId = lectureId
           ..date = date,
         from: lectureRosterControllerProvider,
         name: r'lectureRosterControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$lectureRosterControllerHash,
         dependencies: LectureRosterControllerFamily._dependencies,
         allTransitiveDependencies:
             LectureRosterControllerFamily._allTransitiveDependencies,
         lectureId: lectureId,
         date: date,
       );

  LectureRosterControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lectureId,
    required this.date,
  }) : super.internal();

  final String lectureId;
  final DateTime date;

  @override
  FutureOr<LectureRoster> runNotifierBuild(
    covariant LectureRosterController notifier,
  ) {
    return notifier.build(lectureId: lectureId, date: date);
  }

  @override
  Override overrideWith(LectureRosterController Function() create) {
    return ProviderOverride(
      origin: this,
      override: LectureRosterControllerProvider._internal(
        () => create()
          ..lectureId = lectureId
          ..date = date,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lectureId: lectureId,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    LectureRosterController,
    LectureRoster
  >
  createElement() {
    return _LectureRosterControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LectureRosterControllerProvider &&
        other.lectureId == lectureId &&
        other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lectureId.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LectureRosterControllerRef
    on AutoDisposeAsyncNotifierProviderRef<LectureRoster> {
  /// The parameter `lectureId` of this provider.
  String get lectureId;

  /// The parameter `date` of this provider.
  DateTime get date;
}

class _LectureRosterControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          LectureRosterController,
          LectureRoster
        >
    with LectureRosterControllerRef {
  _LectureRosterControllerProviderElement(super.provider);

  @override
  String get lectureId => (origin as LectureRosterControllerProvider).lectureId;
  @override
  DateTime get date => (origin as LectureRosterControllerProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
