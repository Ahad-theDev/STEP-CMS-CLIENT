// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defaulters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$defaultersControllerHash() =>
    r'ac277064e8df782fe133fe7464d659356d2b7717';

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

abstract class _$DefaultersController
    extends BuildlessAutoDisposeAsyncNotifier<DefaultersResponse> {
  late final double threshold;
  late final DateTime dateFrom;
  late final DateTime dateTo;
  late final String? classId;

  FutureOr<DefaultersResponse> build({
    required double threshold,
    required DateTime dateFrom,
    required DateTime dateTo,
    String? classId,
  });
}

/// See also [DefaultersController].
@ProviderFor(DefaultersController)
const defaultersControllerProvider = DefaultersControllerFamily();

/// See also [DefaultersController].
class DefaultersControllerFamily
    extends Family<AsyncValue<DefaultersResponse>> {
  /// See also [DefaultersController].
  const DefaultersControllerFamily();

  /// See also [DefaultersController].
  DefaultersControllerProvider call({
    required double threshold,
    required DateTime dateFrom,
    required DateTime dateTo,
    String? classId,
  }) {
    return DefaultersControllerProvider(
      threshold: threshold,
      dateFrom: dateFrom,
      dateTo: dateTo,
      classId: classId,
    );
  }

  @override
  DefaultersControllerProvider getProviderOverride(
    covariant DefaultersControllerProvider provider,
  ) {
    return call(
      threshold: provider.threshold,
      dateFrom: provider.dateFrom,
      dateTo: provider.dateTo,
      classId: provider.classId,
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
  String? get name => r'defaultersControllerProvider';
}

/// See also [DefaultersController].
class DefaultersControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          DefaultersController,
          DefaultersResponse
        > {
  /// See also [DefaultersController].
  DefaultersControllerProvider({
    required double threshold,
    required DateTime dateFrom,
    required DateTime dateTo,
    String? classId,
  }) : this._internal(
         () => DefaultersController()
           ..threshold = threshold
           ..dateFrom = dateFrom
           ..dateTo = dateTo
           ..classId = classId,
         from: defaultersControllerProvider,
         name: r'defaultersControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$defaultersControllerHash,
         dependencies: DefaultersControllerFamily._dependencies,
         allTransitiveDependencies:
             DefaultersControllerFamily._allTransitiveDependencies,
         threshold: threshold,
         dateFrom: dateFrom,
         dateTo: dateTo,
         classId: classId,
       );

  DefaultersControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.threshold,
    required this.dateFrom,
    required this.dateTo,
    required this.classId,
  }) : super.internal();

  final double threshold;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? classId;

  @override
  FutureOr<DefaultersResponse> runNotifierBuild(
    covariant DefaultersController notifier,
  ) {
    return notifier.build(
      threshold: threshold,
      dateFrom: dateFrom,
      dateTo: dateTo,
      classId: classId,
    );
  }

  @override
  Override overrideWith(DefaultersController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DefaultersControllerProvider._internal(
        () => create()
          ..threshold = threshold
          ..dateFrom = dateFrom
          ..dateTo = dateTo
          ..classId = classId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        threshold: threshold,
        dateFrom: dateFrom,
        dateTo: dateTo,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    DefaultersController,
    DefaultersResponse
  >
  createElement() {
    return _DefaultersControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DefaultersControllerProvider &&
        other.threshold == threshold &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo &&
        other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, threshold.hashCode);
    hash = _SystemHash.combine(hash, dateFrom.hashCode);
    hash = _SystemHash.combine(hash, dateTo.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DefaultersControllerRef
    on AutoDisposeAsyncNotifierProviderRef<DefaultersResponse> {
  /// The parameter `threshold` of this provider.
  double get threshold;

  /// The parameter `dateFrom` of this provider.
  DateTime get dateFrom;

  /// The parameter `dateTo` of this provider.
  DateTime get dateTo;

  /// The parameter `classId` of this provider.
  String? get classId;
}

class _DefaultersControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          DefaultersController,
          DefaultersResponse
        >
    with DefaultersControllerRef {
  _DefaultersControllerProviderElement(super.provider);

  @override
  double get threshold => (origin as DefaultersControllerProvider).threshold;
  @override
  DateTime get dateFrom => (origin as DefaultersControllerProvider).dateFrom;
  @override
  DateTime get dateTo => (origin as DefaultersControllerProvider).dateTo;
  @override
  String? get classId => (origin as DefaultersControllerProvider).classId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
