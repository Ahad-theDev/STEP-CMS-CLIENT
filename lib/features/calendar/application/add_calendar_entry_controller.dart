import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'calendar_repository_provider.dart';
import '../data/models/calendar_entry_create_request.dart';
import '../data/models/calendar_create_result.dart';

part 'add_calendar_entry_controller.g.dart';

@riverpod
class AddCalendarEntryController extends _$AddCalendarEntryController {
  @override
  FutureOr<void> build() {}

  Future<CalendarCreateResult?> createEntries(CalendarEntryCreateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(calendarRepositoryProvider);
    try {
      final result = await repo.createEntries(request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}