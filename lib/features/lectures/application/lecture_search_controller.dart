import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'lecture_repository_provider.dart';
import '../data/models/lecture.dart';

part 'lecture_search_controller.g.dart';

const int lectureSearchPageSize = 20;

@riverpod
class LectureSearchController extends _$LectureSearchController {
  @override
  Future<List<Lecture>> build({String? classId, String? teacherId, String? dayOfWeek, int page = 1}) async {
    final repo = ref.read(lectureRepositoryProvider);
    return repo.listLectures(
      classId: classId,
      teacherId: teacherId,
      dayOfWeek: dayOfWeek,
      page: page,
      limit: lectureSearchPageSize,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}