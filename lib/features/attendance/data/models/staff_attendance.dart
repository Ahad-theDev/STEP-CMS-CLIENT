class StaffAttendance {
  final String id;
  final String? staffId;
  final String? teacherId;
  final String? personId;
  final String? personName;
  final String? personType;
  final String? designation;
  final String date;
  final String status;
  final String? markedBy;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final bool shortLeave;
  final String? checkInSource;
  final String? checkOutSource;
  final bool isMarked;

  const StaffAttendance({
    required this.id,
    this.staffId,
    this.teacherId,
    this.personId,
    this.personName,
    this.personType,
    this.designation,
    required this.date,
    required this.status,
    this.markedBy,
    this.checkInAt,
    this.checkOutAt,
    this.shortLeave = false,
    this.checkInSource,
    this.checkOutSource,
    this.isMarked = true,
  });

  String get effectivePersonId => personId ?? teacherId ?? staffId ?? id;

  String get effectivePersonType =>
      personType ?? (teacherId != null && teacherId!.isNotEmpty ? 'teacher' : 'staff');

  String get displayName =>
      (personName != null && personName!.trim().isNotEmpty)
          ? personName!.trim()
          : (effectivePersonType == 'teacher' ? 'Teacher' : 'Staff');

  bool get hasIncompleteCheckout => checkInAt != null && checkOutAt == null;

  factory StaffAttendance.fromJson(Map<String, dynamic> json) {
    return StaffAttendance(
      id: json['id']?.toString() ?? '',
      staffId: json['staff_id']?.toString(),
      teacherId: json['teacher_id']?.toString(),
      personId: json['person_id']?.toString(),
      personName: json['person_name']?.toString(),
      personType: json['person_type']?.toString(),
      designation: json['designation']?.toString(),
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'present',
      markedBy: json['marked_by']?.toString(),
      checkInAt: _parseDateTime(json['check_in_at']),
      checkOutAt: _parseDateTime(json['check_out_at']),
      shortLeave: json['short_leave'] == true,
      checkInSource: json['check_in_source']?.toString(),
      checkOutSource: json['check_out_source']?.toString(),
      isMarked: json['is_marked'] != false,
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}