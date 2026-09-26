import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'notification_repository_provider.dart';
import '../data/models/notification_list_response.dart';

part 'notifications_list_controller.g.dart';

const int notificationsPageSize = 20;

@riverpod
class NotificationsListController extends _$NotificationsListController {
  @override
  Future<NotificationListResponse> build({bool? isRead, int page = 1}) async {
    final repo = ref.read(notificationRepositoryProvider);
    return repo.list(page: page, limit: notificationsPageSize, isRead: isRead);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}