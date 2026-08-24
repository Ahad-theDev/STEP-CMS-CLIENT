import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_repository_provider.dart';
import '../data/models/student.dart';

part 'student_search_controller.g.dart';

const int studentSearchPageSize = 20;

@riverpod
class StudentSearchController extends _$StudentSearchController {
  @override
  Future<List<Student>> build({required String classId, int page = 1}) async {
    final repo = ref.read(studentRepositoryProvider);
    return repo.listStudents(classId: classId, page: page, limit: studentSearchPageSize);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}