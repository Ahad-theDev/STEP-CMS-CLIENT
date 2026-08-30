import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'teacher_repository_provider.dart';

part 'delete_teacher_controller.g.dart';

@riverpod
class DeleteTeacherController extends _$DeleteTeacherController {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteTeacher(String teacherId) async {
    state = const AsyncLoading();
    final repo = ref.read(teacherRepositoryProvider);
    try {
      await repo.deleteTeacher(teacherId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}