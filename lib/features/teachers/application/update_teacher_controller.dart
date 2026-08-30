import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'teacher_repository_provider.dart';
import '../data/models/teacher.dart';
import '../data/models/teacher_update_request.dart';

part 'update_teacher_controller.g.dart';

@riverpod
class UpdateTeacherController extends _$UpdateTeacherController {
  @override
  FutureOr<void> build() {}

  Future<Teacher?> updateTeacher(String teacherId, TeacherUpdateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(teacherRepositoryProvider);
    try {
      final teacher = await repo.updateTeacher(teacherId, request);
      state = const AsyncData(null);
      return teacher;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}