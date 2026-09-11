import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'teacher_attendance_repository_provider.dart';
import '../data/models/attendance_mark_request.dart';
import '../data/models/attendance_mark_response.dart';

part 'mark_student_attendance_controller.g.dart';

@riverpod
class MarkStudentAttendanceController extends _$MarkStudentAttendanceController {
  @override
  FutureOr<void> build() {}

  Future<AttendanceMarkResponse?> submit(AttendanceMarkRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(teacherAttendanceRepositoryProvider);
    try {
      final result = await repo.markAttendance(request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}