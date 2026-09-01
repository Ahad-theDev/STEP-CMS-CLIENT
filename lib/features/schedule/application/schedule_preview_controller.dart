import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'schedule_repository_provider.dart';
import '../data/models/schedule_preview_response.dart';

part 'schedule_preview_controller.g.dart';

@riverpod
class SchedulePreviewController extends _$SchedulePreviewController {
  @override
  Future<SchedulePreviewResponse> build({required DateTime date}) async {
    final repo = ref.read(scheduleRepositoryProvider);
    return repo.getPreview(date);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}