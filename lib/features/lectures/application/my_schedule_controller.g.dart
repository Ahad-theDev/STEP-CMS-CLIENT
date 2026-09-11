// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_schedule_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myScheduleControllerHash() =>
    r'6267f1632f99373c7ee3e84a043ed25685561b11';

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

abstract class _$MyScheduleController
    extends BuildlessAutoDisposeAsyncNotifier<MyScheduleResponse> {
  late final String? day;
  late final DateTime? date;

  FutureOr<MyScheduleResponse> build({String? day, DateTime? date});
}

/// See also [MyScheduleController].
@ProviderFor(MyScheduleController)
const myScheduleControllerProvider = MyScheduleControllerFamily();

/// See also [MyScheduleController].
class MyScheduleControllerFamily
    extends Family<AsyncValue<MyScheduleResponse>> {
  /// See also [MyScheduleController].
  const MyScheduleControllerFamily();

  /// See also [MyScheduleController].
  MyScheduleControllerProvider call({String? day, DateTime? date}) {
    return MyScheduleControllerProvider(day: day, date: date);
  }

  @override
  MyScheduleControllerProvider getProviderOverride(
    covariant MyScheduleControllerProvider provider,
  ) {
    return call(day: provider.day, date: provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myScheduleControllerProvider';
}

/// See also [MyScheduleController].
class MyScheduleControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MyScheduleController,
          MyScheduleResponse
        > {
  /// See also [MyScheduleController].
  MyScheduleControllerProvider({String? day, DateTime? date})
    : this._internal(
        () => MyScheduleController()
          ..day = day
          ..date = date,
        from: myScheduleControllerProvider,
        name: r'myScheduleControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myScheduleControllerHash,
        dependencies: MyScheduleControllerFamily._dependencies,
        allTransitiveDependencies:
            MyScheduleControllerFamily._allTransitiveDependencies,
        day: day,
        date: date,
      );

  MyScheduleControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.day,
    required this.date,
  }) : super.internal();

  final String? day;
  final DateTime? date;

  @override
  FutureOr<MyScheduleResponse> runNotifierBuild(
    covariant MyScheduleController notifier,
  ) {
    return notifier.build(day: day, date: date);
  }

  @override
  Override overrideWith(MyScheduleController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MyScheduleControllerProvider._internal(
        () => create()
          ..day = day
          ..date = date,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        day: day,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MyScheduleController,
    MyScheduleResponse
  >
  createElement() {
    return _MyScheduleControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyScheduleControllerProvider &&
        other.day == day &&
        other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, day.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyScheduleControllerRef
    on AutoDisposeAsyncNotifierProviderRef<MyScheduleResponse> {
  /// The parameter `day` of this provider.
  String? get day;

  /// The parameter `date` of this provider.
  DateTime? get date;
}

class _MyScheduleControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MyScheduleController,
          MyScheduleResponse
        >
    with MyScheduleControllerRef {
  _MyScheduleControllerProviderElement(super.provider);

  @override
  String? get day => (origin as MyScheduleControllerProvider).day;
  @override
  DateTime? get date => (origin as MyScheduleControllerProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
