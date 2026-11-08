class DailyRosterStudent {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String? morningStatus;
  final String? closingStatus;
  final String? finalStatus;
  final String? remarks;

  const DailyRosterStudent({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    this.morningStatus,
    this.closingStatus,
    this.finalStatus,
    this.remarks,
  });

  factory DailyRosterStudent.fromJson(Map<String, dynamic> json) {
    return DailyRosterStudent(
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      rollNumber: json['roll_number'] as String,
      morningStatus: json['morning_status'] as String?,
      closingStatus: json['closing_status'] as String?,
      finalStatus: json['final_status'] as String?,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'roll_number': rollNumber,
      'morning_status': morningStatus,
      'closing_status': closingStatus,
      'final_status': finalStatus,
      'remarks': remarks,
    };
  }

  DailyRosterStudent copyWith({
    String? studentId,
    String? studentName,
    String? rollNumber,
    String? morningStatus,
    String? closingStatus,
    String? finalStatus,
    String? remarks,
  }) {
    return DailyRosterStudent(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      morningStatus: morningStatus ?? this.morningStatus,
      closingStatus: closingStatus ?? this.closingStatus,
      finalStatus: finalStatus ?? this.finalStatus,
      remarks: remarks ?? this.remarks,
    );
  }
}

class DailyClassRoster {
  final String classId;
  final String attendanceDate;
  final List<DailyRosterStudent> students;

  const DailyClassRoster({
    required this.classId,
    required this.attendanceDate,
    required this.students,
  });

  factory DailyClassRoster.fromJson(Map<String, dynamic> json) {
    return DailyClassRoster(
      classId: json['class_id'] as String,
      attendanceDate: json['attendance_date'] as String,
      students: (json['students'] as List<dynamic>)
          .map((e) => DailyRosterStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'attendance_date': attendanceDate,
      'students': students.map((s) => s.toJson()).toList(),
    };
  }

  DailyClassRoster copyWith({
    String? classId,
    String? attendanceDate,
    List<DailyRosterStudent>? students,
  }) {
    return DailyClassRoster(
      classId: classId ?? this.classId,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      students: students ?? this.students,
    );
  }
}
