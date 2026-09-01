// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_preview_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$schedulePreviewControllerHash() =>
    r'01e05563d2b4a1727424f7ff49bc909def06c7b5';

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

abstract class _$SchedulePreviewController
    extends BuildlessAutoDisposeAsyncNotifier<SchedulePreviewResponse> {
  late final DateTime date;

  FutureOr<SchedulePreviewResponse> build({required DateTime date});
}

/// See also [SchedulePreviewController].
@ProviderFor(SchedulePreviewController)
const schedulePreviewControllerProvider = SchedulePreviewControllerFamily();

/// See also [SchedulePreviewController].
class SchedulePreviewControllerFamily
    extends Family<AsyncValue<SchedulePreviewResponse>> {
  /// See also [SchedulePreviewController].
  const SchedulePreviewControllerFamily();

  /// See also [SchedulePreviewController].
  SchedulePreviewControllerProvider call({required DateTime date}) {
    return SchedulePreviewControllerProvider(date: date);
  }

  @override
  SchedulePreviewControllerProvider getProviderOverride(
    covariant SchedulePreviewControllerProvider provider,
  ) {
    return call(date: provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'schedulePreviewControllerProvider';
}

/// See also [SchedulePreviewController].
class SchedulePreviewControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          SchedulePreviewController,
          SchedulePreviewResponse
        > {
  /// See also [SchedulePreviewController].
  SchedulePreviewControllerProvider({required DateTime date})
    : this._internal(
        () => SchedulePreviewController()..date = date,
        from: schedulePreviewControllerProvider,
        name: r'schedulePreviewControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$schedulePreviewControllerHash,
        dependencies: SchedulePreviewControllerFamily._dependencies,
        allTransitiveDependencies:
            SchedulePreviewControllerFamily._allTransitiveDependencies,
        date: date,
      );

  SchedulePreviewControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  FutureOr<SchedulePreviewResponse> runNotifierBuild(
    covariant SchedulePreviewController notifier,
  ) {
    return notifier.build(date: date);
  }

  @override
  Override overrideWith(SchedulePreviewController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SchedulePreviewControllerProvider._internal(
        () => create()..date = date,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    SchedulePreviewController,
    SchedulePreviewResponse
  >
  createElement() {
    return _SchedulePreviewControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SchedulePreviewControllerProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SchedulePreviewControllerRef
    on AutoDisposeAsyncNotifierProviderRef<SchedulePreviewResponse> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _SchedulePreviewControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          SchedulePreviewController,
          SchedulePreviewResponse
        >
    with SchedulePreviewControllerRef {
  _SchedulePreviewControllerProviderElement(super.provider);

  @override
  DateTime get date => (origin as SchedulePreviewControllerProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
