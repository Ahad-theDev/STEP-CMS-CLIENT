import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_repository_provider.dart';
import '../data/models/student.dart';

part 'students_list_controller.g.dart';

@riverpod
class StudentsListController extends _$StudentsListController {
  @override
  Future<List<Student>> build() async {
    final repo = ref.read(studentRepositoryProvider);
    return repo.listStudents();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}