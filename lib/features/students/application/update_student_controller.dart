import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_repository_provider.dart';
import '../data/models/student.dart';
import '../data/models/student_update_request.dart';

part 'update_student_controller.g.dart';

@riverpod
class UpdateStudentController extends _$UpdateStudentController {
  @override
  FutureOr<void> build() {}

  Future<Student?> updateStudent(String studentId, StudentUpdateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(studentRepositoryProvider);
    try {
      final student = await repo.updateStudent(studentId, request);
      state = const AsyncData(null);
      return student;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}