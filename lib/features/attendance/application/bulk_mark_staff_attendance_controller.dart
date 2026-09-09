import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'staff_attendance_repository_provider.dart';
import '../data/models/bulk_staff_attendance_request.dart';
import '../data/models/bulk_staff_attendance_response.dart';

part 'bulk_mark_staff_attendance_controller.g.dart';

@riverpod
class BulkMarkStaffAttendanceController extends _$BulkMarkStaffAttendanceController {
  @override
  FutureOr<void> build() {}

  Future<BulkStaffAttendanceResponse?> submit(BulkStaffAttendanceRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(staffAttendanceRepositoryProvider);
    try {
      final result = await repo.bulkMarkAttendance(request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}