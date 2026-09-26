import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'notification_repository_provider.dart';

part 'mark_all_notifications_read_controller.g.dart';

@riverpod
class MarkAllNotificationsReadController extends _$MarkAllNotificationsReadController {
  @override
  FutureOr<void> build() {}

  Future<int?> markAllRead() async {
    state = const AsyncLoading();
    final repo = ref.read(notificationRepositoryProvider);
    try {
      final count = await repo.markAllRead();
      state = const AsyncData(null);
      return count;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}