import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'staff_attendance_repository_provider.dart';
import '../data/models/staff_attendance.dart';
import '../data/models/staff_attendance_mark_request.dart';

part 'mark_staff_attendance_controller.g.dart';

@riverpod
class MarkStaffAttendanceController extends _$MarkStaffAttendanceController {
  @override
  FutureOr<void> build() {}

  Future<StaffAttendance?> markAttendance(StaffAttendanceMarkRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(staffAttendanceRepositoryProvider);
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