import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'lecture_repository_provider.dart';
import '../data/models/lecture_override.dart';
import '../data/models/lecture_override_request.dart';

part 'create_override_controller.g.dart';

@riverpod
class CreateOverrideController extends _$CreateOverrideController {
  @override
  FutureOr<void> build() {}

  Future<LectureOverride?> createOverride(
      String templateLectureId, LectureOverrideRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(lectureRepositoryProvider);
    try {
      final result = await repo.createOverride(templateLectureId, request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}