// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_reminders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feeRemindersControllerHash() =>
    r'460497a7c8f896ddc9850622bf6d982d93870cf9';

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

abstract class _$FeeRemindersController
    extends BuildlessAutoDisposeAsyncNotifier<FeeReminderResponse> {
  late final FeeReminderMode mode;
  late final int days;

  FutureOr<FeeReminderResponse> build({
    required FeeReminderMode mode,
    int days = 3,
  });
}

/// See also [FeeRemindersController].
@ProviderFor(FeeRemindersController)
const feeRemindersControllerProvider = FeeRemindersControllerFamily();

/// See also [FeeRemindersController].
class FeeRemindersControllerFamily
    extends Family<AsyncValue<FeeReminderResponse>> {
  /// See also [FeeRemindersController].
  const FeeRemindersControllerFamily();

  /// See also [FeeRemindersController].
  FeeRemindersControllerProvider call({
    required FeeReminderMode mode,
    int days = 3,
  }) {
    return FeeRemindersControllerProvider(mode: mode, days: days);
  }

  @override
  FeeRemindersControllerProvider getProviderOverride(
    covariant FeeRemindersControllerProvider provider,
  ) {
    return call(mode: provider.mode, days: provider.days);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feeRemindersControllerProvider';
}

/// See also [FeeRemindersController].
class FeeRemindersControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          FeeRemindersController,
          FeeReminderResponse
        > {
  /// See also [FeeRemindersController].
  FeeRemindersControllerProvider({required FeeReminderMode mode, int days = 3})
    : this._internal(
        () => FeeRemindersController()
          ..mode = mode
          ..days = days,
        from: feeRemindersControllerProvider,
        name: r'feeRemindersControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feeRemindersControllerHash,
        dependencies: FeeRemindersControllerFamily._dependencies,
        allTransitiveDependencies:
            FeeRemindersControllerFamily._allTransitiveDependencies,
        mode: mode,
        days: days,
      );

  FeeRemindersControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mode,
    required this.days,
  }) : super.internal();

  final FeeReminderMode mode;
  final int days;

  @override
  FutureOr<FeeReminderResponse> runNotifierBuild(
    covariant FeeRemindersController notifier,
  ) {
    return notifier.build(mode: mode, days: days);
  }

  @override
  Override overrideWith(FeeRemindersController Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeeRemindersControllerProvider._internal(
        () => create()
          ..mode = mode
          ..days = days,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mode: mode,
        days: days,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    FeeRemindersController,
    FeeReminderResponse
  >
  createElement() {
    return _FeeRemindersControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeeRemindersControllerProvider &&
        other.mode == mode &&
        other.days == days;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);
    hash = _SystemHash.combine(hash, days.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeeRemindersControllerRef
    on AutoDisposeAsyncNotifierProviderRef<FeeReminderResponse> {
  /// The parameter `mode` of this provider.
  FeeReminderMode get mode;

  /// The parameter `days` of this provider.
  int get days;
}

class _FeeRemindersControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          FeeRemindersController,
          FeeReminderResponse
        >
    with FeeRemindersControllerRef {
  _FeeRemindersControllerProviderElement(super.provider);

  @override
  FeeReminderMode get mode => (origin as FeeRemindersControllerProvider).mode;
  @override
  int get days => (origin as FeeRemindersControllerProvider).days;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
