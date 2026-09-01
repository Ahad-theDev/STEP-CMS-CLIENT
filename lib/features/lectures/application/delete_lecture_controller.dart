import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'lecture_repository_provider.dart';

part 'delete_lecture_controller.g.dart';

@riverpod
class DeleteLectureController extends _$DeleteLectureController {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteLecture(String lectureId) async {
    state = const AsyncLoading();
    final repo = ref.read(lectureRepositoryProvider);
    try {
      await repo.deleteLecture(lectureId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}