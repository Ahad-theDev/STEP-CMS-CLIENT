import 'package:cms/core/utils/natural_order.dart';
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
    final items = await repo.listAllStudents(classId: classId);
    return [...items]
      ..sort((a, b) => naturalCompare(a.rollNumber, b.rollNumber));
  }
}
