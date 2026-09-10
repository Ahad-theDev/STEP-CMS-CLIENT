import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_attendance_repository_provider.dart';
import '../data/models/bulk_correction_request.dart';
import '../data/models/bulk_correction_response.dart';

part 'bulk_correct_attendance_controller.g.dart';

@riverpod
class BulkCorrectAttendanceController extends _$BulkCorrectAttendanceController {
  @override
  FutureOr<void> build() {}

  Future<BulkCorrectionResponse?> submit(BulkCorrectionRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(studentAttendanceRepositoryProvider);
    try {
      final result = await repo.bulkCorrect(request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}