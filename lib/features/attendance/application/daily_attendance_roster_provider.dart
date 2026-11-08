import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/student_daily_attendance_roster.dart';
import 'daily_attendance_repository_provider.dart';

class DailyRosterQuery {
  final String classId;
  final DateTime date;

  const DailyRosterQuery({required this.classId, required this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRosterQuery &&
          runtimeType == other.runtimeType &&
          classId == other.classId &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day;

  @override
  int get hashCode => Object.hash(classId, date.year, date.month, date.day);
}

final dailyAttendanceRosterProvider = FutureProvider.autoDispose
    .family<DailyClassRoster, DailyRosterQuery>((ref, query) async {
  final repo = ref.watch(dailyAttendanceRepositoryProvider);
  return repo.getRoster(
    classId: query.classId,
    attendanceDate: query.date,
  );
});
