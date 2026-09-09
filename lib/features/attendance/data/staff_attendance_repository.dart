import 'package:cms/features/attendance/data/models/bulk_staff_attendance_request.dart';
import 'package:cms/features/attendance/data/models/bulk_staff_attendance_response.dart';
import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/staff_attendance.dart';
import 'models/staff_attendance_mark_request.dart';

class StaffAttendanceRepository {
  final Dio dio;
  StaffAttendanceRepository(this.dio);

  Future<StaffAttendance> markAttendance(StaffAttendanceMarkRequest request) async {
    final response = await dio.post(ApiConstants.attendanceStaff, data: request.toJson());
    return StaffAttendance.fromJson(response.data);
  }

  /// [personId] works for either a staff or teacher id — the backend's query
  /// param is named "staff_id" regardless of which type it's actually filtering.
  Future<List<StaffAttendance>> listAttendance({DateTime? date, String? personId}) async {
    final response = await dio.get(
      ApiConstants.attendanceStaff,
      queryParameters: {
        if (date != null) 'date': date.toIso8601String().split('T').first,
        if (personId != null) 'staff_id': personId,
      },
    );
    return (response.data as List).map((e) => StaffAttendance.fromJson(e)).toList();
  }

  Future<BulkStaffAttendanceResponse> bulkMarkAttendance(BulkStaffAttendanceRequest request) async {
  final response = await dio.post(ApiConstants.attendanceStaffBulkMark, data: request.toJson());
  return BulkStaffAttendanceResponse.fromJson(response.data);
}
}