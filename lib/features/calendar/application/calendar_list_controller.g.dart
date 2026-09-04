// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarListControllerHash() =>
    r'14d5e7b401b42d05aab222bafac43371c4835626';

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

abstract class _$CalendarListController
    extends BuildlessAutoDisposeAsyncNotifier<List<CalendarEntry>> {
  late final DateTime fromDate;
  late final DateTime toDate;

  FutureOr<List<CalendarEntry>> build({
    required DateTime fromDate,
    required DateTime toDate,
  });
}

/// See also [CalendarListController].
@ProviderFor(CalendarListController)
const calendarListControllerProvider = CalendarListControllerFamily();

/// See also [CalendarListController].
class CalendarListControllerFamily
    extends Family<AsyncValue<List<CalendarEntry>>> {
  /// See also [CalendarListController].
  const CalendarListControllerFamily();

  /// See also [CalendarListController].
  CalendarListControllerProvider call({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    return CalendarListControllerProvider(fromDate: fromDate, toDate: toDate);
  }

  @override
  CalendarListControllerProvider getProviderOverride(
    covariant CalendarListControllerProvider provider,
  ) {
    return call(fromDate: provider.fromDate, toDate: provider.toDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calendarListControllerProvider';
}

/// See also [CalendarListController].
class CalendarListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CalendarListController,
          List<CalendarEntry>
        > {
  /// See also [CalendarListController].
  CalendarListControllerProvider({
    required DateTime fromDate,
    required DateTime toDate,
  }) : this._internal(
         () => CalendarListController()
           ..fromDate = fromDate
           ..toDate = toDate,
         from: calendarListControllerProvider,
         name: r'calendarListControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$calendarListControllerHash,
         dependencies: CalendarListControllerFamily._dependencies,
         allTransitiveDependencies:
             CalendarListControllerFamily._allTransitiveDependencies,
         fromDate: fromDate,
         toDate: toDate,
       );

  CalendarListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fromDate,
    required this.toDate,
  }) : super.internal();

  final DateTime fromDate;
  final DateTime toDate;

  @override
  FutureOr<List<CalendarEntry>> runNotifierBuild(
    covariant CalendarListController notifier,
  ) {
    return notifier.build(fromDate: fromDate, toDate: toDate);
  }

  @override
  Override overrideWith(CalendarListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CalendarListControllerProvider._internal(
        () => create()
          ..fromDate = fromDate
          ..toDate = toDate,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    CalendarListController,
    List<CalendarEntry>
  >
  createElement() {
    return _CalendarListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarListControllerProvider &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fromDate.hashCode);
    hash = _SystemHash.combine(hash, toDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<CalendarEntry>> {
  /// The parameter `fromDate` of this provider.
  DateTime get fromDate;

  /// The parameter `toDate` of this provider.
  DateTime get toDate;
}

class _CalendarListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CalendarListController,
          List<CalendarEntry>
        >
    with CalendarListControllerRef {
  _CalendarListControllerProviderElement(super.provider);

  @override
  DateTime get fromDate => (origin as CalendarListControllerProvider).fromDate;
  @override
  DateTime get toDate => (origin as CalendarListControllerProvider).toDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
