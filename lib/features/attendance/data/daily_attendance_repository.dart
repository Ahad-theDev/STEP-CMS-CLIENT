import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import 'models/student_daily_attendance_roster.dart';
import 'models/morning_attendance_request.dart';
import 'models/closing_attendance_request.dart';
import 'models/daily_attendance_correction_request.dart';
import 'models/daily_attendance_mark_result.dart';

class DailyAttendanceRepository {
  final Dio dio;

  DailyAttendanceRepository(this.dio);

  static String formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Get class roster for a date with any existing morning/closing/final marks.
  Future<DailyClassRoster> getRoster({
    required String classId,
    required DateTime attendanceDate,
  }) async {
    final response = await dio.get(
      ApiConstants.dailyAttendanceRoster(classId),
      queryParameters: {
        'attendance_date': formatDate(attendanceDate),
      },
    );
    return DailyClassRoster.fromJson(response.data as Map<String, dynamic>);
  }

  /// Submit morning checkpoint attendance for the class.
  Future<DailyAttendanceMarkResult> submitMorning({
    required String classId,
    required MorningAttendanceRequest request,
  }) async {
    final response = await dio.put(
      ApiConstants.dailyAttendanceMorning(classId),
      data: request.toJson(),
    );
    return DailyAttendanceMarkResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Submit closing checkpoint attendance for the class.
  Future<DailyAttendanceMarkResult> submitClosing({
    required String classId,
    required ClosingAttendanceRequest request,
  }) async {
    final response = await dio.put(
      ApiConstants.dailyAttendanceClosing(classId),
      data: request.toJson(),
    );
    return DailyAttendanceMarkResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Get class daily attendance summary/roster for a date.
  Future<DailyClassRoster> getClassDailyAttendance({
    required String classId,
    required DateTime attendanceDate,
  }) async {
    final response = await dio.get(
      ApiConstants.dailyAttendanceClass(classId),
      queryParameters: {
        'attendance_date': formatDate(attendanceDate),
      },
    );
    return DailyClassRoster.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get individual student daily attendance history.
  Future<List<Map<String, dynamic>>> getStudentHistory({
    required String studentId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final response = await dio.get(
      ApiConstants.dailyAttendanceStudent(studentId),
      queryParameters: {
        'date_from': formatDate(dateFrom),
        'date_to': formatDate(dateTo),
      },
    );
    return (response.data as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Management-only: Correct student daily attendance with mandatory reason audit.
  Future<Map<String, dynamic>> correctAttendance({
    required String classId,
    required String studentId,
    required DailyAttendanceCorrectionRequest request,
  }) async {
    final response = await dio.patch(
      ApiConstants.dailyAttendanceCorrect(classId, studentId),
      data: request.toJson(),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Get classes authorized for daily attendance:
  /// Teachers receive only the class(es) they are assigned in-charge of.
  /// Management receives all active classes.
  Future<List<SchoolClass>> getAuthorizedClasses() async {
    final response = await dio.get(ApiConstants.dailyAttendanceClasses);
    return (response.data as List)
        .map((e) => SchoolClass.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
