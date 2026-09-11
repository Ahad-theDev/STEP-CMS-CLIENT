import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/lecture_roster.dart';
import 'models/attendance_mark_request.dart';
import 'models/attendance_mark_response.dart';

class TeacherAttendanceRepository {
  final Dio dio;
  TeacherAttendanceRepository(this.dio);

  Future<LectureRoster> getRoster({required String lectureId, required DateTime date}) async {
    final response = await dio.get(
      ApiConstants.lectureRoster(lectureId),
      queryParameters: {'date': date.toIso8601String().split('T').first},
    );
    return LectureRoster.fromJson(response.data);
  }

  Future<AttendanceMarkResponse> markAttendance(AttendanceMarkRequest request) async {
    final response = await dio.post(ApiConstants.attendanceStudentsMark, data: request.toJson());
    return AttendanceMarkResponse.fromJson(response.data);
  }
}