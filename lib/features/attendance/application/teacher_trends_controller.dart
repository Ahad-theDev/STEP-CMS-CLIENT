import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'attendance_analytics_repository_provider.dart';
import '../data/models/teacher_trends_response.dart';

part 'teacher_trends_controller.g.dart';

@riverpod
class TeacherTrendsController extends _$TeacherTrendsController {
  @override
  Future<TeacherTrendsResponse> build({
    required String teacherId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final repo = ref.read(attendanceAnalyticsRepositoryProvider);
    return repo.getTeacherTrends(teacherId: teacherId, dateFrom: dateFrom, dateTo: dateTo);
  }
}