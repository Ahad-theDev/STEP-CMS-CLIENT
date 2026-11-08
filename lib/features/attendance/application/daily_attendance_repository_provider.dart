import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/network/dio_client.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../data/daily_attendance_repository.dart';

final dailyAttendanceRepositoryProvider =
    Provider<DailyAttendanceRepository>((ref) {
  return DailyAttendanceRepository(ref.watch(dioProvider));
});

final dailyAttendanceClassesProvider =
    FutureProvider.autoDispose<List<SchoolClass>>((ref) async {
  final repo = ref.watch(dailyAttendanceRepositoryProvider);
  return repo.getAuthorizedClasses();
});

