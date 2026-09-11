import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/class_trends_response.dart';
import 'models/teacher_trends_response.dart';
import 'models/defaulters_response.dart';

class AttendanceAnalyticsRepository {
  final Dio dio;
  AttendanceAnalyticsRepository(this.dio);

  static String _fmt(DateTime d) => d.toIso8601String().split('T').first;

  Future<ClassTrendsResponse> getClassTrends({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final response = await dio.get(
      ApiConstants.attendanceTrendsClass(classId),
      queryParameters: {'date_from': _fmt(dateFrom), 'date_to': _fmt(dateTo)},
    );
    return ClassTrendsResponse.fromJson(response.data);
  }

  Future<TeacherTrendsResponse> getTeacherTrends({
    required String teacherId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final response = await dio.get(
      ApiConstants.attendanceTrendsTeacher(teacherId),
      queryParameters: {'date_from': _fmt(dateFrom), 'date_to': _fmt(dateTo)},
    );
    return TeacherTrendsResponse.fromJson(response.data);
  }

  /// date_from/date_to are required here (not optional) even though the
  /// backend route technically allows omitting them — omitting them
  /// currently causes the backend to silently return zero defaulters
  /// instead of erroring, so this app never sends that request shape.
  Future<DefaultersResponse> getDefaulters({
    required double threshold,
    required DateTime dateFrom,
    required DateTime dateTo,
    String? classId,
  }) async {
    final response = await dio.get(
      ApiConstants.attendanceDefaulters,
      queryParameters: {
        'threshold': threshold,
        'date_from': _fmt(dateFrom),
        'date_to': _fmt(dateTo),
        if (classId != null) 'class_id': classId,
      },
    );
    return DefaultersResponse.fromJson(response.data);
  }
}