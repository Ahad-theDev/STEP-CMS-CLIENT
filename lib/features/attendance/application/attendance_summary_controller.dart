import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_attendance_repository_provider.dart';
import '../data/models/student_attendance_summary_item.dart';

part 'attendance_summary_controller.g.dart';

@riverpod
class AttendanceSummaryController extends _$AttendanceSummaryController {
  @override
  Future<List<StudentAttendanceSummaryItem>> build({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final repo = ref.read(studentAttendanceRepositoryProvider);
    return repo.getSummary(classId: classId, dateFrom: dateFrom, dateTo: dateTo);
  }
}