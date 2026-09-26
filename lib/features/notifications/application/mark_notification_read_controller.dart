import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'notification_repository_provider.dart';
import '../data/models/notification_item.dart';

part 'mark_notification_read_controller.g.dart';

@riverpod
class MarkNotificationReadController extends _$MarkNotificationReadController {
  @override
  FutureOr<void> build() {}

  Future<NotificationItem?> markRead(String id) async {
    state = const AsyncLoading();
    final repo = ref.read(notificationRepositoryProvider);
    try {
      final result = await repo.markRead(id);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}