import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'lecture_repository_provider.dart';
import '../data/models/lecture.dart';
import '../data/models/lecture_create_request.dart';

part 'add_lecture_controller.g.dart';

@riverpod
class AddLectureController extends _$AddLectureController {
  @override
  FutureOr<void> build() {}

  Future<Lecture?> createLecture(LectureCreateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(lectureRepositoryProvider);
    try {
      final lecture = await repo.createLecture(request);
      state = const AsyncData(null);
      return lecture;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}