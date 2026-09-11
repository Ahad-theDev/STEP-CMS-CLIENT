import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'lecture_repository_provider.dart';
import '../data/models/my_schedule_response.dart';

part 'my_schedule_controller.g.dart';

@riverpod
class MyScheduleController extends _$MyScheduleController {
  @override
  Future<MyScheduleResponse> build({String? day, DateTime? date}) async {
    final repo = ref.read(lectureRepositoryProvider);
    return repo.getMySchedule(day: day, date: date);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}