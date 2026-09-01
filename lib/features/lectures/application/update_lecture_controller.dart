import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'lecture_repository_provider.dart';
import '../data/models/lecture.dart';
import '../data/models/lecture_update_request.dart';

part 'update_lecture_controller.g.dart';

@riverpod
class UpdateLectureController extends _$UpdateLectureController {
  @override
  FutureOr<void> build() {}

  Future<Lecture?> updateLecture(String lectureId, LectureUpdateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(lectureRepositoryProvider);
    try {
      final lecture = await repo.updateLecture(lectureId, request);
      state = const AsyncData(null);
      return lecture;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}