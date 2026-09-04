import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'calendar_repository_provider.dart';
import '../data/models/calendar_entry.dart';

part 'calendar_list_controller.g.dart';

@riverpod
class CalendarListController extends _$CalendarListController {
  @override
  Future<List<CalendarEntry>> build({required DateTime fromDate, required DateTime toDate}) async {
    final repo = ref.read(calendarRepositoryProvider);
    return repo.listEntries(fromDate, toDate);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}