import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'staff_attendance_repository_provider.dart';
import '../data/models/staff_attendance.dart';

part 'staff_attendance_list_controller.g.dart';

@riverpod
class StaffAttendanceListController extends _$StaffAttendanceListController {
  @override
  Future<List<StaffAttendance>> build({DateTime? date, String? personId}) async {
    final repo = ref.read(staffAttendanceRepositoryProvider);
    return repo.listAttendance(date: date, personId: personId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}