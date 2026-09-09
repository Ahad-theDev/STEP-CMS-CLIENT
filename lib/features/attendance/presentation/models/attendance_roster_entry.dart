class AttendanceRosterEntry {
  final String id;
  final String name;
  final String type; // 'staff' | 'teacher'
  final String? originalStatus;
  String? localStatus;

  AttendanceRosterEntry({
    required this.id,
    required this.name,
    required this.type,
    this.originalStatus,
    String? localStatus,
  }) : localStatus = localStatus ?? originalStatus;

  bool get isDirty => localStatus != originalStatus;
}