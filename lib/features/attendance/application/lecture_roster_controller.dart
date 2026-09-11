import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'teacher_attendance_repository_provider.dart';
import '../data/models/lecture_roster.dart';

part 'lecture_roster_controller.g.dart';

@riverpod
class LectureRosterController extends _$LectureRosterController {
  @override
  Future<LectureRoster> build({required String lectureId, required DateTime date}) async {
    final repo = ref.read(teacherAttendanceRepositoryProvider);
    return repo.getRoster(lectureId: lectureId, date: date);
  }
}