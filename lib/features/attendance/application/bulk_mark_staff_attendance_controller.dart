import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/bulk_staff_attendance_request.dart';
import '../data/models/bulk_staff_attendance_response.dart';
import 'staff_attendance_list_controller.dart';
import 'staff_attendance_repository_provider.dart';
import 'teacher_trends_controller.dart';

class BulkMarkStaffAttendanceController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<BulkStaffAttendanceResponse?> submit(
    BulkStaffAttendanceRequest request,
  ) async {
    state = const AsyncLoading();
    final repo = ref.read(staffAttendanceRepositoryProvider);
    try {
      final result = await repo.bulkMarkAttendance(request);
      ref.invalidate(staffAttendanceRosterProvider);
      ref.invalidate(staffAttendanceListProvider);
      ref.invalidate(staffAttendanceSummaryProvider);
      ref.invalidate(staffPersonHistoryProvider);
      ref.invalidate(teacherTrendsControllerProvider);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final bulkMarkStaffAttendanceControllerProvider =
    AutoDisposeAsyncNotifierProvider<BulkMarkStaffAttendanceController, void>(
  BulkMarkStaffAttendanceController.new,
);
