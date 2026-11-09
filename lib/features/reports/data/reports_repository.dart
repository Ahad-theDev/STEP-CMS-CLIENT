import 'package:dio/dio.dart';
import 'package:cms/features/reports/data/models/daily_attendance_report_model.dart';
import 'package:cms/features/reports/data/models/lecture_attendance_report_model.dart';
import 'package:cms/features/reports/data/models/fee_report_model.dart';
import 'package:cms/features/reports/data/models/marks_report_model.dart';

class ReportException implements Exception {
  final String message;
  final int? statusCode;

  ReportException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ReportsRepository {
  final Dio _dio;

  ReportsRepository(this._dio);

  Never _handleError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      String? msg;
      if (data is Map) {
        if (data['error'] is Map && data['error']['message'] != null) {
          msg = data['error']['message'].toString();
        } else if (data['detail'] != null) {
          if (data['detail'] is List) {
            msg = (data['detail'] as List)
                .map((item) => item is Map ? item['msg'] : item.toString())
                .join(', ');
          } else {
            msg = data['detail'].toString();
          }
        } else if (data['message'] != null) {
          msg = data['message'].toString();
        }
      }
      throw ReportException(
        msg ?? e.message ?? 'An unexpected network error occurred',
        e.response?.statusCode,
      );
    }
    throw ReportException(e.toString());
  }

  /// 1. Daily Attendance Report (GET /reports/attendance/daily)
  Future<DailyAttendanceReport> getDailyAttendanceReport({
    String? classId,
    String? studentId,
    List<String>? studentIds,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final q = <String, dynamic>{};
      if (classId != null && classId.isNotEmpty) q['class_id'] = classId;
      if (studentId != null && studentId.isNotEmpty) q['student_id'] = studentId;
      if (studentIds != null && studentIds.isNotEmpty) {
        q['student_ids'] = studentIds;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) q['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) q['date_to'] = dateTo;

      final response = await _dio.get(
        '/reports/attendance/daily',
        queryParameters: q,
      );
      return DailyAttendanceReport.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// 2. Lecture Attendance Report (GET /reports/attendance/lectures)
  Future<LectureAttendanceReport> getLectureAttendanceReport({
    required String dateFrom,
    required String dateTo,
    String? classId,
    String? studentId,
    List<String>? studentIds,
  }) async {
    try {
      final q = <String, dynamic>{
        'date_from': dateFrom,
        'date_to': dateTo,
      };
      if (classId != null && classId.isNotEmpty) q['class_id'] = classId;
      if (studentId != null && studentId.isNotEmpty) q['student_id'] = studentId;
      if (studentIds != null && studentIds.isNotEmpty) {
        q['student_ids'] = studentIds;
      }

      final response = await _dio.get(
        '/reports/attendance/lectures',
        queryParameters: q,
      );
      return LectureAttendanceReport.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// 3. Fee Report (GET /reports/fees)
  Future<FeeReport> getFeeReport({
    String? classId,
    String? studentId,
    List<String>? studentIds,
    String? dateFrom,
    String? dateTo,
    int? month,
    int? year,
  }) async {
    try {
      final q = <String, dynamic>{};
      if (classId != null && classId.isNotEmpty) q['class_id'] = classId;
      if (studentId != null && studentId.isNotEmpty) q['student_id'] = studentId;
      if (studentIds != null && studentIds.isNotEmpty) {
        q['student_ids'] = studentIds;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) q['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) q['date_to'] = dateTo;
      if (month != null) q['month'] = month;
      if (year != null) q['year'] = year;

      final response = await _dio.get('/reports/fees', queryParameters: q);
      return FeeReport.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleError(e);
    }
  }

  /// 4. Marks Report (GET /reports/marks)
  Future<MarksReport> getMarksReport({
    required String examId,
    String? classId,
    String? studentId,
    List<String>? studentIds,
  }) async {
    try {
      final q = <String, dynamic>{
        'exam_id': examId,
      };
      if (classId != null && classId.isNotEmpty) q['class_id'] = classId;
      if (studentId != null && studentId.isNotEmpty) q['student_id'] = studentId;
      if (studentIds != null && studentIds.isNotEmpty) {
        q['student_ids'] = studentIds;
      }

      final response = await _dio.get('/reports/marks', queryParameters: q);
      return MarksReport.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleError(e);
    }
  }
}
