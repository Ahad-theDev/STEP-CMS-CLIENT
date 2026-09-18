// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feeSummaryControllerHash() =>
    r'cda094402aff2fd9a64444fe5893e97bdaf330ce';

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

abstract class _$FeeSummaryController
    extends BuildlessAutoDisposeAsyncNotifier<FeeSummaryResponse> {
  late final String? classId;
  late final int? fromMonth;
  late final int? fromYear;
  late final int? toMonth;
  late final int? toYear;

  FutureOr<FeeSummaryResponse> build({
    String? classId,
    int? fromMonth,
    int? fromYear,
    int? toMonth,
    int? toYear,
  });
}

/// See also [FeeSummaryController].
@ProviderFor(FeeSummaryController)
const feeSummaryControllerProvider = FeeSummaryControllerFamily();

/// See also [FeeSummaryController].
class FeeSummaryControllerFamily
    extends Family<AsyncValue<FeeSummaryResponse>> {
  /// See also [FeeSummaryController].
  const FeeSummaryControllerFamily();

  /// See also [FeeSummaryController].
  FeeSummaryControllerProvider call({
    String? classId,
    int? fromMonth,
    int? fromYear,
    int? toMonth,
    int? toYear,
  }) {
    return FeeSummaryControllerProvider(
      classId: classId,
      fromMonth: fromMonth,
      fromYear: fromYear,
      toMonth: toMonth,
      toYear: toYear,
    );
  }

  @override
  FeeSummaryControllerProvider getProviderOverride(
    covariant FeeSummaryControllerProvider provider,
  ) {
    return call(
      classId: provider.classId,
      fromMonth: provider.fromMonth,
      fromYear: provider.fromYear,
      toMonth: provider.toMonth,
      toYear: provider.toYear,
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
  String? get name => r'feeSummaryControllerProvider';
}

/// See also [FeeSummaryController].
class FeeSummaryControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          FeeSummaryController,
          FeeSummaryResponse
        > {
  /// See also [FeeSummaryController].
  FeeSummaryControllerProvider({
    String? classId,
    int? fromMonth,
    int? fromYear,
    int? toMonth,
    int? toYear,
  }) : this._internal(
         () => FeeSummaryController()
           ..classId = classId
           ..fromMonth = fromMonth
           ..fromYear = fromYear
           ..toMonth = toMonth
           ..toYear = toYear,
         from: feeSummaryControllerProvider,
         name: r'feeSummaryControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$feeSummaryControllerHash,
         dependencies: FeeSummaryControllerFamily._dependencies,
         allTransitiveDependencies:
             FeeSummaryControllerFamily._allTransitiveDependencies,
         classId: classId,
         fromMonth: fromMonth,
         fromYear: fromYear,
         toMonth: toMonth,
         toYear: toYear,
       );

  FeeSummaryControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.fromMonth,
    required this.fromYear,
    required this.toMonth,
    required this.toYear,
  }) : super.internal();

  final String? classId;
  final int? fromMonth;
  final int? fromYear;
  final int? toMonth;
  final int? toYear;

  @override
  FutureOr<FeeSummaryResponse> runNotifierBuild(
    covariant FeeSummaryController notifier,
  ) {
    return notifier.build(
      classId: classId,
      fromMonth: fromMonth,
      fromYear: fromYear,
      toMonth: toMonth,
      toYear: toYear,
    );
  }

  @override
  Override overrideWith(FeeSummaryController Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeeSummaryControllerProvider._internal(
        () => create()
          ..classId = classId
          ..fromMonth = fromMonth
          ..fromYear = fromYear
          ..toMonth = toMonth
          ..toYear = toYear,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        fromMonth: fromMonth,
        fromYear: fromYear,
        toMonth: toMonth,
        toYear: toYear,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    FeeSummaryController,
    FeeSummaryResponse
  >
  createElement() {
    return _FeeSummaryControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeeSummaryControllerProvider &&
        other.classId == classId &&
        other.fromMonth == fromMonth &&
        other.fromYear == fromYear &&
        other.toMonth == toMonth &&
        other.toYear == toYear;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, fromMonth.hashCode);
    hash = _SystemHash.combine(hash, fromYear.hashCode);
    hash = _SystemHash.combine(hash, toMonth.hashCode);
    hash = _SystemHash.combine(hash, toYear.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeeSummaryControllerRef
    on AutoDisposeAsyncNotifierProviderRef<FeeSummaryResponse> {
  /// The parameter `classId` of this provider.
  String? get classId;

  /// The parameter `fromMonth` of this provider.
  int? get fromMonth;

  /// The parameter `fromYear` of this provider.
  int? get fromYear;

  /// The parameter `toMonth` of this provider.
  int? get toMonth;

  /// The parameter `toYear` of this provider.
  int? get toYear;
}

class _FeeSummaryControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          FeeSummaryController,
          FeeSummaryResponse
        >
    with FeeSummaryControllerRef {
  _FeeSummaryControllerProviderElement(super.provider);

  @override
  String? get classId => (origin as FeeSummaryControllerProvider).classId;
  @override
  int? get fromMonth => (origin as FeeSummaryControllerProvider).fromMonth;
  @override
  int? get fromYear => (origin as FeeSummaryControllerProvider).fromYear;
  @override
  int? get toMonth => (origin as FeeSummaryControllerProvider).toMonth;
  @override
  int? get toYear => (origin as FeeSummaryControllerProvider).toYear;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
