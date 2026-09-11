import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'attendance_analytics_repository_provider.dart';
import '../data/models/class_trends_response.dart';

part 'class_trends_controller.g.dart';

@riverpod
class ClassTrendsController extends _$ClassTrendsController {
  @override
  Future<ClassTrendsResponse> build({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final repo = ref.read(attendanceAnalyticsRepositoryProvider);
    return repo.getClassTrends(classId: classId, dateFrom: dateFrom, dateTo: dateTo);
  }
}