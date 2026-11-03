import 'package:cms/core/utils/fetch_all_pages.dart';
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'notification_repository_provider.dart';
import '../data/models/notification_item.dart';

part 'unread_notifications_controller.g.dart';

@riverpod
class UnreadNotificationsController extends _$UnreadNotificationsController {
  @override
  Future<List<NotificationItem>> build() async {
    final repo = ref.read(notificationRepositoryProvider);
    return fetchAllPages<NotificationItem>(
      fetch: (page, limit) async =>
          (await repo.list(page: page, limit: limit, isRead: false)).items,
      idOf: (item) => item.id,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
