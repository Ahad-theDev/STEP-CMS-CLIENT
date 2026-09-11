import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/attendance_analytics_repository.dart';

part 'attendance_analytics_repository_provider.g.dart';

@riverpod
AttendanceAnalyticsRepository attendanceAnalyticsRepository(AttendanceAnalyticsRepositoryRef ref) {
  return AttendanceAnalyticsRepository(ref.read(dioProvider));
}