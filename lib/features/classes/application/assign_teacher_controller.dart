import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'class_repository_provider.dart';
import '../data/models/assign_teacher_request.dart';

part 'assign_teacher_controller.g.dart';

@riverpod
class AssignTeacherController extends _$AssignTeacherController {
  @override
  FutureOr<void> build() {}

  Future<bool> assignTeacher(String classId, AssignTeacherRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(classRepositoryProvider);
    try {
      await repo.assignTeacher(classId, request);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}