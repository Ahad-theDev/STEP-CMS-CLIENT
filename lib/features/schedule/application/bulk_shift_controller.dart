import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'schedule_repository_provider.dart';
import 'package:cms/features/students/data/models/bulk_import_result.dart';
import '../data/models/bulk_shift_request.dart';

part 'bulk_shift_controller.g.dart';

@riverpod
class BulkShiftController extends _$BulkShiftController {
  @override
  FutureOr<void> build() {}

  Future<BulkImportResult?> shift(BulkShiftRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(scheduleRepositoryProvider);
    try {
      final result = await repo.bulkShift(request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}