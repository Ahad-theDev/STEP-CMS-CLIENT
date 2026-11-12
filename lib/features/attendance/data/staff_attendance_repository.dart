import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:dio/dio.dart';
import 'models/bulk_staff_attendance_request.dart';
import 'models/bulk_staff_attendance_response.dart';
import 'models/staff_attendance.dart';
import 'models/staff_attendance_mark_request.dart';
import 'models/staff_attendance_unified_models.dart';

class StaffAttendanceRepository {
  final Dio _dio;

  StaffAttendanceRepository(this._dio);

  /// GET /attendance/staff/roster?date=YYYY-MM-DD
  Future<List<StaffAttendanceRosterItem>> getRoster({
    required DateTime date,
  }) async {
    final res = await _dio.get(
      ApiConstants.attendanceStaffRoster,
      queryParameters: {'date': formatApiDate(date)},
    );
    final raw = res.data as List<dynamic>? ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(StaffAttendanceRosterItem.fromJson)
        .toList();
  }

  /// POST /attendance/staff
  Future<StaffAttendance> markAttendance(
    StaffAttendanceMarkRequest request,
  ) async {
    final res = await _dio.post(
      ApiConstants.attendanceStaff,
      data: request.toJson(),
    );
    return StaffAttendance.fromJson(res.data as Map<String, dynamic>);
  }

  /// POST /attendance/staff/bulk-mark
  Future<BulkStaffAttendanceResponse> bulkMarkAttendance(
    BulkStaffAttendanceRequest request,
  ) async {
    final res = await _dio.post(
      ApiConstants.attendanceStaffBulkMark,
      data: request.toJson(),
    );
    return BulkStaffAttendanceResponse.fromJson(
      res.data as Map<String, dynamic>,
    );
  }

  /// PATCH /attendance/staff/{attendance_id}
  Future<StaffAttendance> editAttendance({
    required String attendanceId,
    required StaffAttendanceEditRequest request,
  }) async {
    final res = await _dio.patch(
      ApiConstants.attendanceStaffItem(attendanceId),
      data: request.toJson(),
    );
    return StaffAttendance.fromJson(res.data as Map<String, dynamic>);
  }

  /// GET /attendance/staff
  Future<List<StaffAttendance>> listAttendance({
    DateTime? date,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? personType,
    String? personId,
    String? status,
    bool? shortLeave,
  }) async {
    final query = <String, dynamic>{};
    if (date != null) {
      query['date'] = formatApiDate(date);
    } else if (dateFrom != null && dateTo != null) {
      query['date_from'] = formatApiDate(dateFrom);
      query['date_to'] = formatApiDate(dateTo);
    }
    if (personType != null && personType.isNotEmpty) {
      query['person_type'] = personType;
    }
    if (personId != null && personId.isNotEmpty) {
      query['person_id'] = personId;
    }
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    if (shortLeave != null) {
      query['short_leave'] = shortLeave;
    }

    final res = await _dio.get(
      ApiConstants.attendanceStaff,
      queryParameters: query.isEmpty ? null : query,
    );
    final raw = res.data as List<dynamic>? ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(StaffAttendance.fromJson)
        .toList();
  }

  /// GET /attendance/staff/summary
  Future<StaffAttendanceSummaryResponse> getSummary({
    required DateTime dateFrom,
    required DateTime dateTo,
    String? personType,
    String? personId,
  }) async {
    final query = <String, dynamic>{
      'date_from': formatApiDate(dateFrom),
      'date_to': formatApiDate(dateTo),
    };
    if (personType != null &&
        personType.isNotEmpty &&
        personId != null &&
        personId.isNotEmpty) {
      query['person_type'] = personType;
      query['person_id'] = personId;
    }
    final res = await _dio.get(
      ApiConstants.attendanceStaffSummary,
      queryParameters: query,
    );
    return StaffAttendanceSummaryResponse.fromJson(
      res.data as Map<String, dynamic>,
    );
  }

  /// GET /attendance/staff/{person_type}/{person_id}/history
  Future<List<StaffAttendance>> getPersonHistory({
    required String personType,
    required String personId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final query = <String, dynamic>{};
    if (dateFrom != null && dateTo != null) {
      query['date_from'] = formatApiDate(dateFrom);
      query['date_to'] = formatApiDate(dateTo);
    }
    final res = await _dio.get(
      ApiConstants.attendanceStaffHistory(personType, personId),
      queryParameters: query.isEmpty ? null : query,
    );
    final raw = res.data as List<dynamic>? ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(StaffAttendance.fromJson)
        .toList();
  }

  /// GET /attendance/staff/{attendance_id}/audit
  Future<List<StaffAttendanceAuditItem>> getAuditTrail(
    String attendanceId,
  ) async {
    final res = await _dio.get(ApiConstants.attendanceStaffAudit(attendanceId));
    final raw = res.data as List<dynamic>? ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(StaffAttendanceAuditItem.fromJson)
        .toList();
  }
}