import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/staff_attendance_repository.dart';

part 'staff_attendance_repository_provider.g.dart';

@riverpod
StaffAttendanceRepository staffAttendanceRepository(StaffAttendanceRepositoryRef ref) {
  return StaffAttendanceRepository(ref.read(dioProvider));
}