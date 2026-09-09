import 'bulk_staff_attendance_entry.dart';

class BulkStaffAttendanceRequest {
  final DateTime date;
  final List<BulkStaffAttendanceEntry> entries;

  BulkStaffAttendanceRequest({required this.date, required this.entries});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T').first,
        'entries': entries.map((e) => e.toJson()).toList(),
      };
}