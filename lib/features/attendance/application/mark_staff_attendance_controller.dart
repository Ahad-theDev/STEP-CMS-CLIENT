import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/staff_attendance.dart';
import '../data/models/staff_attendance_mark_request.dart';
import '../data/models/staff_attendance_unified_models.dart';
import 'staff_attendance_list_controller.dart';
import 'staff_attendance_repository_provider.dart';
import 'teacher_trends_controller.dart';

class MarkStaffAttendanceController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<StaffAttendance?> markAttendance(
    StaffAttendanceMarkRequest request,
  ) async {
    state = const AsyncLoading();
    final repo = ref.read(staffAttendanceRepositoryProvider);
    try {
      final result = await repo.markAttendance(request);
      _invalidateRelatedProviders(attendanceId: result.id);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<StaffAttendance?> editAttendance({
    required String attendanceId,
    required StaffAttendanceEditRequest request,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(staffAttendanceRepositoryProvider);
    try {
      final result = await repo.editAttendance(
        attendanceId: attendanceId,
        request: request,
      );
      _invalidateRelatedProviders(attendanceId: result.id);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  void _invalidateRelatedProviders({String? attendanceId}) {
    ref.invalidate(staffAttendanceRosterProvider);
    ref.invalidate(staffAttendanceListProvider);
    ref.invalidate(staffAttendanceSummaryProvider);
    ref.invalidate(staffPersonHistoryProvider);
    if (attendanceId != null && attendanceId.isNotEmpty) {
      ref.invalidate(staffAttendanceAuditProvider(attendanceId));
    }
    ref.invalidate(teacherTrendsControllerProvider);
  }
}

final markStaffAttendanceControllerProvider =
    AutoDisposeAsyncNotifierProvider<MarkStaffAttendanceController, void>(
  MarkStaffAttendanceController.new,
);
