// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsListControllerHash() =>
    r'7afa9c0ae85f521e39f3605281378549d03bdbf0';

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

abstract class _$NotificationsListController
    extends BuildlessAutoDisposeAsyncNotifier<NotificationListResponse> {
  late final bool? isRead;
  late final int page;

  FutureOr<NotificationListResponse> build({bool? isRead, int page = 1});
}

/// See also [NotificationsListController].
@ProviderFor(NotificationsListController)
const notificationsListControllerProvider = NotificationsListControllerFamily();

/// See also [NotificationsListController].
class NotificationsListControllerFamily
    extends Family<AsyncValue<NotificationListResponse>> {
  /// See also [NotificationsListController].
  const NotificationsListControllerFamily();

  /// See also [NotificationsListController].
  NotificationsListControllerProvider call({bool? isRead, int page = 1}) {
    return NotificationsListControllerProvider(isRead: isRead, page: page);
  }

  @override
  NotificationsListControllerProvider getProviderOverride(
    covariant NotificationsListControllerProvider provider,
  ) {
    return call(isRead: provider.isRead, page: provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'notificationsListControllerProvider';
}

/// See also [NotificationsListController].
class NotificationsListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          NotificationsListController,
          NotificationListResponse
        > {
  /// See also [NotificationsListController].
  NotificationsListControllerProvider({bool? isRead, int page = 1})
    : this._internal(
        () => NotificationsListController()
          ..isRead = isRead
          ..page = page,
        from: notificationsListControllerProvider,
        name: r'notificationsListControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$notificationsListControllerHash,
        dependencies: NotificationsListControllerFamily._dependencies,
        allTransitiveDependencies:
            NotificationsListControllerFamily._allTransitiveDependencies,
        isRead: isRead,
        page: page,
      );

  NotificationsListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isRead,
    required this.page,
  }) : super.internal();

  final bool? isRead;
  final int page;

  @override
  FutureOr<NotificationListResponse> runNotifierBuild(
    covariant NotificationsListController notifier,
  ) {
    return notifier.build(isRead: isRead, page: page);
  }

  @override
  Override overrideWith(NotificationsListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: NotificationsListControllerProvider._internal(
        () => create()
          ..isRead = isRead
          ..page = page,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isRead: isRead,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    NotificationsListController,
    NotificationListResponse
  >
  createElement() {
    return _NotificationsListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationsListControllerProvider &&
        other.isRead == isRead &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isRead.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotificationsListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<NotificationListResponse> {
  /// The parameter `isRead` of this provider.
  bool? get isRead;

  /// The parameter `page` of this provider.
  int get page;
}

class _NotificationsListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          NotificationsListController,
          NotificationListResponse
        >
    with NotificationsListControllerRef {
  _NotificationsListControllerProviderElement(super.provider);

  @override
  bool? get isRead => (origin as NotificationsListControllerProvider).isRead;
  @override
  int get page => (origin as NotificationsListControllerProvider).page;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
