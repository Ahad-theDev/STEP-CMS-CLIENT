import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_repository_provider.dart';
import '../data/models/student.dart';
import '../data/models/student_create_request.dart';

part 'add_student_controller.g.dart';

@riverpod
class AddStudentController extends _$AddStudentController {
  @override
  FutureOr<void> build() {}

  Future<Student?> createStudent(StudentCreateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(studentRepositoryProvider);
    try {
      final student = await repo.createStudent(request);
      state = const AsyncData(null);
      return student;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}