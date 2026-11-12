import 'package:cms/core/utils/attendance_event_utils.dart';
import 'bulk_staff_attendance_entry.dart';

class BulkStaffAttendanceRequest {
  final String date; // YYYY-MM-DD
  final DateTime? defaultCheckInAt;
  final DateTime? defaultCheckOutAt;
  final String? reason;
  final List<BulkStaffAttendanceEntry> entries;

  const BulkStaffAttendanceRequest({
    required this.date,
    this.defaultCheckInAt,
    this.defaultCheckOutAt,
    this.reason,
    required this.entries,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'date': date,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
    if (defaultCheckInAt != null) {
      map['default_check_in_at'] = formatIsoWithLocalOffset(defaultCheckInAt!);
    }
    if (defaultCheckOutAt != null) {
      map['default_check_out_at'] =
          formatIsoWithLocalOffset(defaultCheckOutAt!);
    }
    if (reason != null && reason!.trim().isNotEmpty) {
      map['reason'] = reason!.trim();
    }
    return map;
  }
}