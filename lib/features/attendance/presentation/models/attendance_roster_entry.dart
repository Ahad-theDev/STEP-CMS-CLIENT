class AttendanceRosterEntry {
  final String id;
  final String name;
  final String type; // 'staff' | 'teacher'
  String? markedStatus;

  AttendanceRosterEntry({
    required this.id,
    required this.name,
    required this.type,
    this.markedStatus,
  });
}