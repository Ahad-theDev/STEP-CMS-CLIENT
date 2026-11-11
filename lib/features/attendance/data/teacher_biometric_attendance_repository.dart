import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:dio/dio.dart';
import 'models/teacher_attendance_models.dart';

class TeacherBiometricAttendanceRepository {
  final Dio dio;

  TeacherBiometricAttendanceRepository(this.dio);

  Future<AttendanceDeviceCreated> registerDevice(
    AttendanceDeviceCreateRequest request,
  ) async {
    final response = await dio.post(
      ApiConstants.attendanceDevices,
      data: request.toJson(),
    );
    return AttendanceDeviceCreated.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<AttendanceDevice>> listDevices() async {
    final response = await dio.get(ApiConstants.attendanceDevices);
    return (response.data as List<dynamic>)
        .map((e) => AttendanceDevice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttendanceDevice> setDeviceActive(
    String deviceId,
    bool isActive,
  ) async {
    final response = await dio.patch(
      ApiConstants.attendanceDevice(deviceId),
      data: {'is_active': isActive},
    );
    return AttendanceDevice.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FingerprintEnrollment> enrollTeacherFingerprint(
    String teacherId,
    FingerprintEnrollmentRequest request,
  ) async {
    final response = await dio.post(
      ApiConstants.teacherFingerprintEnrollment(teacherId),
      data: request.toJson(),
    );
    return FingerprintEnrollment.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<FingerprintEnrollment>> listTeacherEnrollments(
    String teacherId,
  ) async {
    final response = await dio.get(
      ApiConstants.teacherFingerprintEnrollment(teacherId),
    );
    return (response.data as List<dynamic>)
        .map((e) => FingerprintEnrollment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> revokeTeacherEnrollment(
    String teacherId,
    String deviceId,
  ) async {
    await dio.delete(
      ApiConstants.revokeTeacherFingerprintEnrollment(teacherId, deviceId),
    );
  }

  Future<List<AttendancePolicyDay>> getPolicy() async {
    final response = await dio.get(ApiConstants.attendancePolicy);
    return (response.data as List<dynamic>)
        .map((e) => AttendancePolicyDay.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendancePolicyDay>> updatePolicy(
    List<AttendancePolicyDay> weekdays,
  ) async {
    final response = await dio.put(
      ApiConstants.attendancePolicy,
      data: {'weekdays': weekdays.map((d) => d.toInputJson()).toList()},
    );
    return (response.data as List<dynamic>)
        .map((e) => AttendancePolicyDay.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TeacherScanResponse> submitFingerprintScan({
    required TeacherScanRequest request,
    required String deviceToken,
  }) async {
    final response = await dio.post(
      ApiConstants.teacherScan,
      data: request.toJson(),
      options: Options(
        headers: {'X-Attendance-Device-Token': deviceToken},
      ),
    );
    return TeacherScanResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TeacherScanResponse> submitManualEvent(
    TeacherManualEventRequest request,
  ) async {
    final response = await dio.post(
      ApiConstants.teacherManualEvent,
      data: request.toJson(),
    );
    return TeacherScanResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TeacherDailyAttendanceItem>> getDailyAttendance({
    DateTime? date,
  }) async {
    final response = await dio.get(
      ApiConstants.teacherDailyAttendance,
      queryParameters: {
        if (date != null) 'date': formatApiDate(date),
      },
    );
    return (response.data as List<dynamic>)
        .map(
          (e) =>
              TeacherDailyAttendanceItem.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<TeacherAttendanceSummary> getSummary({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final response = await dio.get(
      ApiConstants.teacherAttendanceSummary,
      queryParameters: {
        'date_from': formatApiDate(dateFrom),
        'date_to': formatApiDate(dateTo),
      },
    );
    return TeacherAttendanceSummary.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
