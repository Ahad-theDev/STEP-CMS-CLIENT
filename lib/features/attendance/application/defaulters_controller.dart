import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'attendance_analytics_repository_provider.dart';
import '../data/models/defaulters_response.dart';

part 'defaulters_controller.g.dart';

@riverpod
class DefaultersController extends _$DefaultersController {
  @override
  Future<DefaultersResponse> build({
    required double threshold,
    required DateTime dateFrom,
    required DateTime dateTo,
    String? classId,
  }) async {
    final repo = ref.read(attendanceAnalyticsRepositoryProvider);
    return repo.getDefaulters(threshold: threshold, dateFrom: dateFrom, dateTo: dateTo, classId: classId);
  }
}