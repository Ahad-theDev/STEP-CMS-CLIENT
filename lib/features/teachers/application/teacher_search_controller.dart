import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'teacher_repository_provider.dart';
import '../data/models/teacher.dart';

part 'teacher_search_controller.g.dart';

const int teacherSearchPageSize = 20;

@riverpod
class TeacherSearchController extends _$TeacherSearchController {
  @override
  Future<List<Teacher>> build({String? department, String? subjectId, int page = 1}) async {
    final repo = ref.read(teacherRepositoryProvider);
    return repo.searchTeachers(
      department: department,
      subjectSpecializationId: subjectId,
      page: page,
      limit: teacherSearchPageSize,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}