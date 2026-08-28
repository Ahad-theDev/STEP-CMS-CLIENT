import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'teacher_repository_provider.dart';
import '../data/models/teacher.dart';

part 'teachers_list_controller.g.dart';

@riverpod
class TeachersListController extends _$TeachersListController {
  @override
  Future<List<Teacher>> build() async {
    final repo = ref.read(teacherRepositoryProvider);
    return repo.listTeachers();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}