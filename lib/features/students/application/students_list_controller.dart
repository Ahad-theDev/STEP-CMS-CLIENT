import 'package:cms/core/utils/natural_order.dart';
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
    final items = await repo.listAllStudents();
    return [...items]
      ..sort((a, b) => naturalCompare(a.rollNumber, b.rollNumber));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
