import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_repository_provider.dart';

part 'delete_student_controller.g.dart';

@riverpod
class DeleteStudentController extends _$DeleteStudentController {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteStudent(String studentId) async {
    state = const AsyncLoading();
    final repo = ref.read(studentRepositoryProvider);
    try {
      await repo.deleteStudent(studentId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}