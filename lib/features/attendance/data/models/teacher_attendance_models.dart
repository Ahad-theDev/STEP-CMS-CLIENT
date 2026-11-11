import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:cms/core/utils/numeric_utils.dart';

class AttendanceDevice {
  final String id;
  final String deviceName;
  final String deviceIdentifier;
  final String? deviceModel;
  final bool isActive;
  final DateTime registeredAt;
  final DateTime? lastSeenAt;

  const AttendanceDevice({
    required this.id,
    required this.deviceName,
    required this.deviceIdentifier,
    this.deviceModel,
    required this.isActive,
    required this.registeredAt,
    this.lastSeenAt,
  });

  factory AttendanceDevice.fromJson(Map<String, dynamic> json) =>
      AttendanceDevice(
        id: json['id'] as String,
        deviceName: json['device_name'] as String,
        deviceIdentifier: json['device_identifier'] as String,
        deviceModel: json['device_model'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        registeredAt: DateTime.parse(json['registered_at'] as String),
        lastSeenAt: json['last_seen_at'] != null
            ? DateTime.tryParse(json['last_seen_at'] as String)
            : null,
      );
}

class AttendanceDeviceCreated extends AttendanceDevice {
  final String deviceToken;

  const AttendanceDeviceCreated({
    required super.id,
    required super.deviceName,
    required super.deviceIdentifier,
    super.deviceModel,
    required super.isActive,
    required super.registeredAt,
    super.lastSeenAt,
    required this.deviceToken,
  });

  factory AttendanceDeviceCreated.fromJson(Map<String, dynamic> json) =>
      AttendanceDeviceCreated(
        id: json['id'] as String,
        deviceName: json['device_name'] as String,
        deviceIdentifier: json['device_identifier'] as String,
        deviceModel: json['device_model'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        registeredAt: DateTime.parse(json['registered_at'] as String),
        lastSeenAt: json['last_seen_at'] != null
            ? DateTime.tryParse(json['last_seen_at'] as String)
            : null,
        deviceToken: json['device_token'] as String,
      );
}

class AttendanceDeviceCreateRequest {
  final String deviceName;
  final String deviceIdentifier;
  final String? deviceModel;

  const AttendanceDeviceCreateRequest({
    required this.deviceName,
    required this.deviceIdentifier,
    this.deviceModel,
  });

  Map<String, dynamic> toJson() => {
        'device_name': deviceName.trim(),
        'device_identifier': deviceIdentifier.trim(),
        if (deviceModel != null && deviceModel!.trim().isNotEmpty)
          'device_model': deviceModel!.trim(),
      };
}

class FingerprintEnrollment {
  final String id;
  final String teacherId;
  final String deviceId;
  final String? templateReference;
  final String? templateVersion;
  final bool isActive;
  final DateTime enrolledAt;

  const FingerprintEnrollment({
    required this.id,
    required this.teacherId,
    required this.deviceId,
    this.templateReference,
    this.templateVersion,
    required this.isActive,
    required this.enrolledAt,
  });

  factory FingerprintEnrollment.fromJson(Map<String, dynamic> json) =>
      FingerprintEnrollment(
        id: json['id'] as String,
        teacherId: json['teacher_id'] as String,
        deviceId: json['device_id'] as String,
        templateReference: json['template_reference'] as String?,
        templateVersion: json['template_version'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      );
}

class FingerprintEnrollmentRequest {
  final String deviceId;
  final String? templateReference;
  final String? templateVersion;

  const FingerprintEnrollmentRequest({
    required this.deviceId,
    this.templateReference,
    this.templateVersion,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        if (templateReference != null && templateReference!.trim().isNotEmpty)
          'template_reference': templateReference!.trim(),
        if (templateVersion != null && templateVersion!.trim().isNotEmpty)
          'template_version': templateVersion!.trim(),
      };
}

class AttendancePolicyDay {
  final String? id;
  final int weekday; // Monday=0 through Sunday=6
  final String startTime; // HH:MM:SS
  final String endTime; // HH:MM:SS
  final String checkInCutoff; // HH:MM:SS
  final int lateGraceMinutes;
  final int earlyLeaveGraceMinutes;
  final bool isActive;

  const AttendancePolicyDay({
    this.id,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.checkInCutoff,
    this.lateGraceMinutes = 10,
    this.earlyLeaveGraceMinutes = 5,
    this.isActive = true,
  });

  static const List<String> weekdayLabels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get weekdayName =>
      (weekday >= 0 && weekday < weekdayLabels.length)
          ? weekdayLabels[weekday]
          : 'Day $weekday';

  factory AttendancePolicyDay.defaultForDay(int weekday) => AttendancePolicyDay(
        weekday: weekday,
        startTime: '07:45:00',
        endTime: '14:00:00',
        checkInCutoff: '09:00:00',
        lateGraceMinutes: 10,
        earlyLeaveGraceMinutes: 5,
        isActive: weekday < 6, // Mon-Sat active, Sunday inactive by default
      );

  factory AttendancePolicyDay.fromJson(Map<String, dynamic> json) =>
      AttendancePolicyDay(
        id: json['id'] as String?,
        weekday: parseInt(json['weekday']),
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        checkInCutoff: json['check_in_cutoff'] as String,
        lateGraceMinutes: parseInt(json['late_grace_minutes']),
        earlyLeaveGraceMinutes: parseInt(json['early_leave_grace_minutes']),
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toInputJson() => {
        'weekday': weekday,
        'start_time': startTime,
        'end_time': endTime,
        'check_in_cutoff': checkInCutoff,
        'late_grace_minutes': lateGraceMinutes,
        'early_leave_grace_minutes': earlyLeaveGraceMinutes,
        'is_active': isActive,
      };

  AttendancePolicyDay copyWith({
    String? id,
    int? weekday,
    String? startTime,
    String? endTime,
    String? checkInCutoff,
    int? lateGraceMinutes,
    int? earlyLeaveGraceMinutes,
    bool? isActive,
  }) =>
      AttendancePolicyDay(
        id: id ?? this.id,
        weekday: weekday ?? this.weekday,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        checkInCutoff: checkInCutoff ?? this.checkInCutoff,
        lateGraceMinutes: lateGraceMinutes ?? this.lateGraceMinutes,
        earlyLeaveGraceMinutes:
            earlyLeaveGraceMinutes ?? this.earlyLeaveGraceMinutes,
        isActive: isActive ?? this.isActive,
      );

  /// Mirrors the backend's 5 validation checks in save_policy_weekdays so
  /// management gets instant inline feedback before submission.
  String? validate() {
    if (lateGraceMinutes < 0 || lateGraceMinutes > 240) {
      return '$weekdayName: Late grace must be between 0 and 240 minutes.';
    }
    if (earlyLeaveGraceMinutes < 0 || earlyLeaveGraceMinutes > 240) {
      return '$weekdayName: Early-leave grace must be between 0 and 240 minutes.';
    }
    final startMin = timeOfDayToMinutes(parseApiTimeOfDay(startTime));
    final endMin = timeOfDayToMinutes(parseApiTimeOfDay(endTime));
    final cutoffMin = timeOfDayToMinutes(parseApiTimeOfDay(checkInCutoff));
    final lateBoundary = startMin + lateGraceMinutes;

    if (endMin <= startMin) {
      return '$weekdayName: End time must be after start time.';
    }
    if (cutoffMin < startMin) {
      return '$weekdayName: Check-in cutoff cannot be before start time.';
    }
    if (cutoffMin > endMin) {
      return '$weekdayName: Check-in cutoff cannot be after end time.';
    }
    if (lateBoundary > endMin) {
      return '$weekdayName: Late grace period extends past end time.';
    }
    if (cutoffMin < lateBoundary) {
      return '$weekdayName: Check-in cutoff cannot be earlier than start time + late grace.';
    }
    return null;
  }
}

class TeacherScanRequest {
  final String eventId;
  final String teacherId;
  final String deviceId;
  final String eventType; // 'check_in' | 'check_out'
  final String capturedAt; // ISO-8601 with timezone offset

  const TeacherScanRequest({
    required this.eventId,
    required this.teacherId,
    required this.deviceId,
    required this.eventType,
    required this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'teacher_id': teacherId,
        'device_id': deviceId,
        'event_type': eventType,
        'captured_at': capturedAt,
      };
}

class TeacherManualEventRequest {
  final String eventId;
  final String teacherId;
  final String eventType; // 'check_in' | 'check_out'

  const TeacherManualEventRequest({
    required this.eventId,
    required this.teacherId,
    required this.eventType,
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'teacher_id': teacherId,
        'event_type': eventType,
      };
}

class TeacherScanResponse {
  final bool success;
  final bool duplicate;
  final String teacherId;
  final String teacherName;
  final String eventType;
  final String attendanceStatus;
  final String attendanceDate;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final bool shortLeave;
  final String message;

  const TeacherScanResponse({
    required this.success,
    required this.duplicate,
    required this.teacherId,
    required this.teacherName,
    required this.eventType,
    required this.attendanceStatus,
    required this.attendanceDate,
    this.checkInAt,
    this.checkOutAt,
    required this.shortLeave,
    required this.message,
  });

  factory TeacherScanResponse.fromJson(Map<String, dynamic> json) =>
      TeacherScanResponse(
        success: json['success'] as bool? ?? true,
        duplicate: json['duplicate'] as bool? ?? false,
        teacherId: json['teacher_id'] as String,
        teacherName: json['teacher_name'] as String? ?? '',
        eventType: json['event_type'] as String,
        attendanceStatus: json['attendance_status'] as String,
        attendanceDate: json['attendance_date'] as String,
        checkInAt: json['check_in_at'] != null
            ? DateTime.tryParse(json['check_in_at'] as String)
            : null,
        checkOutAt: json['check_out_at'] != null
            ? DateTime.tryParse(json['check_out_at'] as String)
            : null,
        shortLeave: json['short_leave'] as bool? ?? false,
        message: json['message'] as String? ?? '',
      );
}

class TeacherDailyAttendanceItem {
  final String attendanceId;
  final String teacherId;
  final String teacherName;
  final String date;
  final String status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final bool shortLeave;
  final String? checkInSource;
  final String? checkOutSource;

  const TeacherDailyAttendanceItem({
    required this.attendanceId,
    required this.teacherId,
    required this.teacherName,
    required this.date,
    required this.status,
    this.checkInAt,
    this.checkOutAt,
    required this.shortLeave,
    this.checkInSource,
    this.checkOutSource,
  });

  factory TeacherDailyAttendanceItem.fromJson(Map<String, dynamic> json) =>
      TeacherDailyAttendanceItem(
        attendanceId: json['attendance_id'] as String,
        teacherId: json['teacher_id'] as String,
        teacherName: json['teacher_name'] as String,
        date: json['date'] as String,
        status: json['status'] as String,
        checkInAt: json['check_in_at'] != null
            ? DateTime.tryParse(json['check_in_at'] as String)
            : null,
        checkOutAt: json['check_out_at'] != null
            ? DateTime.tryParse(json['check_out_at'] as String)
            : null,
        shortLeave: json['short_leave'] as bool? ?? false,
        checkInSource: json['check_in_source'] as String?,
        checkOutSource: json['check_out_source'] as String?,
      );
}

class TeacherAttendanceSummary {
  final String dateFrom;
  final String dateTo;
  final int totalRecords;
  final int present;
  final int late;
  final int absent;
  final int leave;
  final int shortLeave;

  const TeacherAttendanceSummary({
    required this.dateFrom,
    required this.dateTo,
    required this.totalRecords,
    required this.present,
    required this.late,
    required this.absent,
    required this.leave,
    required this.shortLeave,
  });

  factory TeacherAttendanceSummary.fromJson(Map<String, dynamic> json) =>
      TeacherAttendanceSummary(
        dateFrom: json['date_from'] as String,
        dateTo: json['date_to'] as String,
        totalRecords: parseInt(json['total_records']),
        present: parseInt(json['present']),
        late: parseInt(json['late']),
        absent: parseInt(json['absent']),
        leave: parseInt(json['leave']),
        shortLeave: parseInt(json['short_leave']),
      );
}
