import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'lecture_repository_provider.dart';
import '../data/models/lecture.dart';

part 'all_lectures_for_class_controller.g.dart';

@riverpod
class AllLecturesForClassController extends _$AllLecturesForClassController {
  @override
  Future<List<Lecture>> build({required String classId}) async {
    final repo = ref.read(lectureRepositoryProvider);
    return repo.listLectures(classId: classId, page: 1, limit: 200);
  }
}