import 'package:cms/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/staff_attendance_repository.dart';

final staffAttendanceRepositoryProvider =
    Provider<StaffAttendanceRepository>((ref) {
  return StaffAttendanceRepository(ref.watch(dioProvider));
});