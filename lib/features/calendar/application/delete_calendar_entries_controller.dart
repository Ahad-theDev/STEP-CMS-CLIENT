import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'calendar_repository_provider.dart';
import '../data/models/calendar_delete_result.dart';

part 'delete_calendar_entries_controller.g.dart';

@riverpod
class DeleteCalendarEntriesController extends _$DeleteCalendarEntriesController {
  @override
  FutureOr<void> build() {}

  Future<CalendarDeleteResult?> deleteEntries(DateTime dateFrom, DateTime? dateTo) async {
    state = const AsyncLoading();
    final repo = ref.read(calendarRepositoryProvider);
    try {
      final result = await repo.deleteEntries(dateFrom, dateTo);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}