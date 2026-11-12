import 'package:cms/core/utils/attendance_event_utils.dart';

class StaffAttendanceMarkRequest {
  final String personType; // 'teacher' | 'staff'
  final String personId;
  final String date; // YYYY-MM-DD
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String? status; // only 'absent' | 'leave' when used explicitly
  final bool? shortLeave;
  final String? reason;

  const StaffAttendanceMarkRequest({
    required this.personType,
    required this.personId,
    required this.date,
    this.checkInAt,
    this.checkOutAt,
    this.status,
    this.shortLeave,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'person_type': personType,
      'person_id': personId,
      'date': date,
    };
    final isAbsenceOrLeave = status == 'absent' || status == 'leave';
    if (isAbsenceOrLeave) {
      map['status'] = status;
    } else {
      if (checkInAt != null) {
        map['check_in_at'] = formatIsoWithLocalOffset(checkInAt!);
      }
      if (checkOutAt != null) {
        map['check_out_at'] = formatIsoWithLocalOffset(checkOutAt!);
      }
      if (shortLeave != null) {
        map['short_leave'] = shortLeave;
      }
    }
    if (reason != null && reason!.trim().isNotEmpty) {
      map['reason'] = reason!.trim();
    }
    return map;
  }
}