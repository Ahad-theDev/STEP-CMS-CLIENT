import 'dart:async';
import 'package:cms/features/students/application/student_repository_provider.dart';
import 'package:cms/features/students/data/models/student.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'all_students_controller.g.dart';

@riverpod
class AllStudentsController extends _$AllStudentsController {
  @override
  Future<List<Student>> build() async {
    final repo = ref.read(studentRepositoryProvider);
    return repo.listStudents(page: 1, limit: 500);
  }
}