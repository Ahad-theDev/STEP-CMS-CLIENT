import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/schedule_repository.dart';

part 'schedule_repository_provider.g.dart';

@riverpod
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) {
  return ScheduleRepository(ref.read(dioProvider));
}