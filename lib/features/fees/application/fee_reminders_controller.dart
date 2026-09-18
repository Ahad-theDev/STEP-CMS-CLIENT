import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_record_repository_provider.dart';
import '../data/models/fee_reminder_response.dart';

part 'fee_reminders_controller.g.dart';

enum FeeReminderMode { dueToday, overdue, upcoming }

@riverpod
class FeeRemindersController extends _$FeeRemindersController {
  @override
  Future<FeeReminderResponse> build({required FeeReminderMode mode, int days = 3}) async {
    final repo = ref.read(feeRecordRepositoryProvider);
    switch (mode) {
      case FeeReminderMode.dueToday:
        return repo.getDueToday();
      case FeeReminderMode.overdue:
        return repo.getOverdue();
      case FeeReminderMode.upcoming:
        return repo.getUpcoming(days);
    }
  }
}