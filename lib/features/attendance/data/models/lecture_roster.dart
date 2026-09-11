class RosterStudent {
  final String id;
  final String name;
  final String rollNumber;

  RosterStudent({
    required this.id,
    required this.name,
    required this.rollNumber,
  });

  factory RosterStudent.fromJson(Map<String, dynamic> json) => RosterStudent(
    id: json['id'] as String,
    name: json['full_name'] as String,
    rollNumber: json['roll_number'] as String,
  );
}

class LectureRoster {
  final String lectureId;
  final String classId;
  final String subject;
  final String date;
  final List<RosterStudent> students;

  LectureRoster({
    required this.lectureId,
    required this.classId,
    required this.subject,
    required this.date,
    required this.students,
  });

  factory LectureRoster.fromJson(Map<String, dynamic> json) => LectureRoster(
    lectureId: json['lecture_id'] as String,
    classId: json['class_id'] as String,
    subject: json['subject'] as String,
    date: json['date'] as String,
    students: (json['students'] as List)
        .map((e) => RosterStudent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
