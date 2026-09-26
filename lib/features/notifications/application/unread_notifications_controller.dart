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
    return repo.getUnread(limit: 100);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}