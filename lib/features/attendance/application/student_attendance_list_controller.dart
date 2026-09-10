import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_attendance_repository_provider.dart';
import '../data/models/student_attendance_record.dart';

part 'student_attendance_list_controller.g.dart';

@riverpod
class StudentAttendanceListController extends _$StudentAttendanceListController {
  @override
  Future<List<StudentAttendanceRecord>> build({required String classId, DateTime? date}) async {
    final repo = ref.read(studentAttendanceRepositoryProvider);
    return repo.listAttendance(classId: classId, date: date);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}