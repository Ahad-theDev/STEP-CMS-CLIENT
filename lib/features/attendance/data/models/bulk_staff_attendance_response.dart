class BulkStaffAttendanceResultItem {
  final String personId;
  final String action; // created | updated | skipped_duplicate

  BulkStaffAttendanceResultItem({required this.personId, required this.action});

  factory BulkStaffAttendanceResultItem.fromJson(Map<String, dynamic> json) =>
      BulkStaffAttendanceResultItem(
        personId: json['person_id'] as String,
        action: json['action'] as String,
      );
}

class BulkStaffAttendanceResponse {
  final String date;
  final List<BulkStaffAttendanceResultItem> results;

  BulkStaffAttendanceResponse({required this.date, required this.results});

  factory BulkStaffAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      BulkStaffAttendanceResponse(
        date: json['date'] as String,
        results: (json['results'] as List)
            .map((e) => BulkStaffAttendanceResultItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}