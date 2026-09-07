class StaffAttendance {
  final String id;
  final String? staffId;
  final String? teacherId;
  final String personName;
  final String personType; // staff | teacher
  final String date;
  final String status; // present | absent | late | leave
  final String markedBy;

  StaffAttendance({
    required this.id,
    this.staffId,
    this.teacherId,
    required this.personName,
    required this.personType,
    required this.date,
    required this.status,
    required this.markedBy,
  });

  factory StaffAttendance.fromJson(Map<String, dynamic> json) => StaffAttendance(
        id: json['id'] as String,
        staffId: json['staff_id'] as String?,
        teacherId: json['teacher_id'] as String?,
        personName: json['person_name'] as String,
        personType: json['person_type'] as String,
        date: json['date'] as String,
        status: json['status'] as String,
        markedBy: json['marked_by'] as String,
      );
}