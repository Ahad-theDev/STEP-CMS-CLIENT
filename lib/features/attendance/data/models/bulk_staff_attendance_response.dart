class BulkStaffAttendanceResultItem {
  final String personId;
  final String personType;
  final String attendanceId;
  final String action;

  const BulkStaffAttendanceResultItem({
    required this.personId,
    required this.personType,
    required this.attendanceId,
    required this.action,
  });

  factory BulkStaffAttendanceResultItem.fromJson(Map<String, dynamic> json) {
    return BulkStaffAttendanceResultItem(
      personId: json['person_id']?.toString() ?? '',
      personType: json['person_type']?.toString() ?? 'staff',
      attendanceId: json['attendance_id']?.toString() ?? '',
      action: json['action']?.toString() ?? 'created',
    );
  }
}

class BulkStaffAttendanceResponse {
  final String date;
  final int savedCount;
  final List<BulkStaffAttendanceResultItem> results;

  const BulkStaffAttendanceResponse({
    required this.date,
    required this.savedCount,
    required this.results,
  });

  factory BulkStaffAttendanceResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? const [];
    return BulkStaffAttendanceResponse(
      date: json['date']?.toString() ?? '',
      savedCount: (json['saved_count'] as num?)?.toInt() ?? rawResults.length,
      results: rawResults
          .whereType<Map<String, dynamic>>()
          .map(BulkStaffAttendanceResultItem.fromJson)
          .toList(),
    );
  }
}