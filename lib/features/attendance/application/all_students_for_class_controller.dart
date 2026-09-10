import 'dart:async';
import 'package:cms/features/students/application/student_repository_provider.dart';
import 'package:cms/features/students/data/models/student.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_students_for_class_controller.g.dart';

@riverpod
class AllStudentsForClassController extends _$AllStudentsForClassController {
  @override
  Future<List<Student>> build({required String classId}) async {
    final repo = ref.read(studentRepositoryProvider);
    return repo.listStudents(classId: classId, page: 1, limit: 200);
  }
}