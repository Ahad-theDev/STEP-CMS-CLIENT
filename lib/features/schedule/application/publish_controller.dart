import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'schedule_repository_provider.dart';
import '../data/models/publish_result.dart';

part 'publish_controller.g.dart';

@riverpod
class PublishController extends _$PublishController {
  @override
  FutureOr<void> build() {}

  Future<PublishResult?> publish(DateTime date) async {
    state = const AsyncLoading();
    final repo = ref.read(scheduleRepositoryProvider);
    try {
      final result = await repo.publish(date);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}