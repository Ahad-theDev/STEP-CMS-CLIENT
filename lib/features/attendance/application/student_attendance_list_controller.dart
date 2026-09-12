import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_attendance_repository_provider.dart';
import '../data/models/student_attendance_record.dart';

part 'student_attendance_list_controller.g.dart';

@riverpod
class StudentAttendanceListController extends _$StudentAttendanceListController {
  @override
  Future<List<StudentAttendanceRecord>> build({
    String? classId,
    DateTime? date,
    String? lectureId,
    String? studentId,
    String? status,
  }) async {
    final repo = ref.read(studentAttendanceRepositoryProvider);
    return repo.listAttendance(
      classId: classId,
      date: date,
      lectureId: lectureId,
      studentId: studentId,
      status: status,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}