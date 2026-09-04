import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/calendar_repository.dart';

part 'calendar_repository_provider.g.dart';

@riverpod
CalendarRepository calendarRepository(CalendarRepositoryRef ref) {
  return CalendarRepository(ref.read(dioProvider));
}