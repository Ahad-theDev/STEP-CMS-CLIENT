import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/daily_attendance_repository.dart';
import '../data/models/morning_attendance_request.dart';
import '../data/models/closing_attendance_request.dart';
import '../data/models/daily_attendance_correction_request.dart';
import '../data/models/daily_attendance_mark_result.dart';
import 'daily_attendance_repository_provider.dart';

class SubmitDailyAttendanceController
    extends StateNotifier<AsyncValue<DailyAttendanceMarkResult?>> {
  final DailyAttendanceRepository _repo;

  SubmitDailyAttendanceController(this._repo) : super(const AsyncData(null));

  Future<DailyAttendanceMarkResult?> submitMorning({
    required String classId,
    required MorningAttendanceRequest request,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _repo.submitMorning(classId: classId, request: request);
      state = AsyncData(res);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<DailyAttendanceMarkResult?> submitClosing({
    required String classId,
    required ClosingAttendanceRequest request,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _repo.submitClosing(classId: classId, request: request);
      state = AsyncData(res);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> correctAttendance({
    required String classId,
    required String studentId,
    required DailyAttendanceCorrectionRequest request,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.correctAttendance(
        classId: classId,
        studentId: studentId,
        request: request,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final submitDailyAttendanceControllerProvider = StateNotifierProvider<
    SubmitDailyAttendanceController,
    AsyncValue<DailyAttendanceMarkResult?>>((ref) {
  return SubmitDailyAttendanceController(
    ref.watch(dailyAttendanceRepositoryProvider),
  );
});
