import 'package:cms/core/utils/attendance_event_utils.dart';

class StaffAttendanceRosterItem {
  final String personId;
  final String personType; // 'teacher' | 'staff'
  final String personName;
  final String? designation;
  final String? attendanceId;
  final String date;
  final String? status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final bool shortLeave;
  final String? checkInSource;
  final String? checkOutSource;
  final bool isMarked;

  const StaffAttendanceRosterItem({
    required this.personId,
    required this.personType,
    required this.personName,
    this.designation,
    this.attendanceId,
    required this.date,
    this.status,
    this.checkInAt,
    this.checkOutAt,
    this.shortLeave = false,
    this.checkInSource,
    this.checkOutSource,
    required this.isMarked,
  });

  String get rosterKey => '$personType:$personId';

  bool get isTeacher => personType == 'teacher';

  factory StaffAttendanceRosterItem.fromJson(Map<String, dynamic> json) {
    return StaffAttendanceRosterItem(
      personId: json['person_id']?.toString() ?? '',
      personType: json['person_type']?.toString() ?? 'staff',
      personName: json['person_name']?.toString() ?? 'Unknown',
      designation: json['designation']?.toString(),
      attendanceId: json['attendance_id']?.toString(),
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString(),
      checkInAt: _parseNullableDateTime(json['check_in_at']),
      checkOutAt: _parseNullableDateTime(json['check_out_at']),
      shortLeave: json['short_leave'] == true,
      checkInSource: json['check_in_source']?.toString(),
      checkOutSource: json['check_out_source']?.toString(),
      isMarked: json['is_marked'] == true,
    );
  }
}

class StaffAttendanceEditRequest {
  final String? status; // null means don't override; 'absent'|'leave' sets disposition
  final DateTime? checkInAt;
  final bool clearCheckIn;
  final DateTime? checkOutAt;
  final bool clearCheckOut;
  final bool? shortLeave;
  final String reason;

  const StaffAttendanceEditRequest({
    this.status,
    this.checkInAt,
    this.clearCheckIn = false,
    this.checkOutAt,
    this.clearCheckOut = false,
    this.shortLeave,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'reason': reason.trim(),
    };
    if (status == 'absent' || status == 'leave') {
      map['status'] = status;
    } else {
      if (status != null) {
        map['status'] = status;
      }
      if (clearCheckIn) {
        map['check_in_at'] = null;
      } else if (checkInAt != null) {
        map['check_in_at'] = formatIsoWithLocalOffset(checkInAt!);
      }
      if (clearCheckOut) {
        map['check_out_at'] = null;
      } else if (checkOutAt != null) {
        map['check_out_at'] = formatIsoWithLocalOffset(checkOutAt!);
      }
      if (shortLeave != null) {
        map['short_leave'] = shortLeave;
      }
    }
    return map;
  }
}

class StaffAttendanceAuditItem {
  final String id;
  final String attendanceId;
  final String eventType;
  final String source;
  final DateTime occurredAt;
  final DateTime receivedAt;
  final String actorUserId;
  final String? deviceId;
  final String idempotencyKey;
  final String? oldStatus;
  final String? newStatus;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? reason;

  const StaffAttendanceAuditItem({
    required this.id,
    required this.attendanceId,
    required this.eventType,
    required this.source,
    required this.occurredAt,
    required this.receivedAt,
    required this.actorUserId,
    this.deviceId,
    required this.idempotencyKey,
    this.oldStatus,
    this.newStatus,
    this.oldValues,
    this.newValues,
    this.reason,
  });

  factory StaffAttendanceAuditItem.fromJson(Map<String, dynamic> json) {
    return StaffAttendanceAuditItem(
      id: json['id']?.toString() ?? '',
      attendanceId: json['attendance_id']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      occurredAt: _parseNullableDateTime(json['occurred_at']) ?? DateTime.now(),
      receivedAt: _parseNullableDateTime(json['received_at']) ?? DateTime.now(),
      actorUserId: json['actor_user_id']?.toString() ?? '',
      deviceId: json['device_id']?.toString(),
      idempotencyKey: json['idempotency_key']?.toString() ?? '',
      oldStatus: json['old_status']?.toString(),
      newStatus: json['new_status']?.toString(),
      oldValues: json['old_values'] is Map
          ? Map<String, dynamic>.from(json['old_values'] as Map)
          : null,
      newValues: json['new_values'] is Map
          ? Map<String, dynamic>.from(json['new_values'] as Map)
          : null,
      reason: json['reason']?.toString(),
    );
  }
}

class StaffPersonSummary {
  final String personId;
  final String personType;
  final String personName;
  final int totalRecords;
  final int present;
  final int late;
  final int absent;
  final int leave;
  final int shortLeaveDays;
  final int checkInCount;
  final int checkOutCount;
  final int incompleteCheckouts;
  final int totalWorkedMinutes;
  final double attendancePercentage;

  const StaffPersonSummary({
    required this.personId,
    required this.personType,
    required this.personName,
    required this.totalRecords,
    required this.present,
    required this.late,
    required this.absent,
    required this.leave,
    required this.shortLeaveDays,
    required this.checkInCount,
    required this.checkOutCount,
    required this.incompleteCheckouts,
    required this.totalWorkedMinutes,
    required this.attendancePercentage,
  });

  factory StaffPersonSummary.fromJson(Map<String, dynamic> json) {
    return StaffPersonSummary(
      personId: json['person_id']?.toString() ?? '',
      personType: json['person_type']?.toString() ?? 'staff',
      personName: json['person_name']?.toString() ?? '',
      totalRecords: (json['total_records'] as num?)?.toInt() ?? 0,
      present: (json['present'] as num?)?.toInt() ?? 0,
      late: (json['late'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
      leave: (json['leave'] as num?)?.toInt() ?? 0,
      shortLeaveDays: (json['short_leave_days'] as num?)?.toInt() ?? 0,
      checkInCount: (json['check_in_count'] as num?)?.toInt() ?? 0,
      checkOutCount: (json['check_out_count'] as num?)?.toInt() ?? 0,
      incompleteCheckouts: (json['incomplete_checkouts'] as num?)?.toInt() ?? 0,
      totalWorkedMinutes: (json['total_worked_minutes'] as num?)?.toInt() ?? 0,
      attendancePercentage:
          (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StaffAttendanceSummaryResponse {
  final String dateFrom;
  final String dateTo;
  final int totalRecords;
  final int present;
  final int late;
  final int absent;
  final int leave;
  final int shortLeaveDays;
  final int checkInCount;
  final int checkOutCount;
  final int incompleteCheckouts;
  final int totalWorkedMinutes;
  final double attendancePercentage;
  final int peopleWithRecords;
  final List<StaffPersonSummary> people;
  final String summaryBasis;

  const StaffAttendanceSummaryResponse({
    required this.dateFrom,
    required this.dateTo,
    required this.totalRecords,
    required this.present,
    required this.late,
    required this.absent,
    required this.leave,
    required this.shortLeaveDays,
    required this.checkInCount,
    required this.checkOutCount,
    required this.incompleteCheckouts,
    required this.totalWorkedMinutes,
    required this.attendancePercentage,
    required this.peopleWithRecords,
    required this.people,
    required this.summaryBasis,
  });

  factory StaffAttendanceSummaryResponse.fromJson(Map<String, dynamic> json) {
    final rawPeople = json['people'] as List<dynamic>? ?? const [];
    return StaffAttendanceSummaryResponse(
      dateFrom: json['date_from']?.toString() ?? '',
      dateTo: json['date_to']?.toString() ?? '',
      totalRecords: (json['total_records'] as num?)?.toInt() ?? 0,
      present: (json['present'] as num?)?.toInt() ?? 0,
      late: (json['late'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
      leave: (json['leave'] as num?)?.toInt() ?? 0,
      shortLeaveDays: (json['short_leave_days'] as num?)?.toInt() ?? 0,
      checkInCount: (json['check_in_count'] as num?)?.toInt() ?? 0,
      checkOutCount: (json['check_out_count'] as num?)?.toInt() ?? 0,
      incompleteCheckouts: (json['incomplete_checkouts'] as num?)?.toInt() ?? 0,
      totalWorkedMinutes: (json['total_worked_minutes'] as num?)?.toInt() ?? 0,
      attendancePercentage:
          (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
      peopleWithRecords: (json['people_with_records'] as num?)?.toInt() ?? 0,
      people: rawPeople
          .whereType<Map<String, dynamic>>()
          .map(StaffPersonSummary.fromJson)
          .toList(),
      summaryBasis: json['summary_basis']?.toString() ?? 'saved_records_only',
    );
  }
}

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
