import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/student_attendance_record.dart';
import 'models/student_attendance_summary_item.dart';
import 'models/bulk_correction_request.dart';
import 'models/bulk_correction_response.dart';

class StudentAttendanceRepository {
  final Dio dio;
  StudentAttendanceRepository(this.dio);

  static String _fmt(DateTime d) => d.toIso8601String().split('T').first;

  Future<List<StudentAttendanceRecord>> listAttendance({
    String? lectureId,
    String? classId,
    DateTime? date,
    String? studentId,
    String? status,
  }) async {
    final response = await dio.get(
      ApiConstants.attendanceStudents,
      queryParameters: {
        ...? (lectureId != null ? {'lecture_id': lectureId} : null),
        ...? (classId != null ? {'class_id': classId} : null),
        ...? (date != null ? {'date': _fmt(date)} : null),
        ...? (studentId != null ? {'student_id': studentId} : null),
        ...? (status != null ? {'attendance_status': status} : null),
      },
    );
    return (response.data as List).map((e) => StudentAttendanceRecord.fromJson(e)).toList();
  }

  Future<List<StudentAttendanceSummaryItem>> getSummary({
    required String classId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final response = await dio.get(
      ApiConstants.attendanceStudentsSummary,
      queryParameters: {
        'class_id': classId,
        'date_from': _fmt(dateFrom),
        'date_to': _fmt(dateTo),
      },
    );
    return (response.data['students'] as List)
        .map((e) => StudentAttendanceSummaryItem.fromJson(e))
        .toList();
  }

  Future<BulkCorrectionResponse> bulkCorrect(BulkCorrectionRequest request) async {
    final response =
        await dio.patch(ApiConstants.attendanceStudentsBulkCorrect, data: request.toJson());
    return BulkCorrectionResponse.fromJson(response.data);
  }
}