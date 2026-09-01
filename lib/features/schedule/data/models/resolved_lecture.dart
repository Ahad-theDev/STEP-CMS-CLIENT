class ResolvedLecture {
  final String classId;
  final String subjectId;
  final String teacherId;
  final String roomNumber;
  final String startTime;
  final String endTime;
  final String status;

  ResolvedLecture({
    required this.classId,
    required this.subjectId,
    required this.teacherId,
    required this.roomNumber,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory ResolvedLecture.fromJson(Map<String, dynamic> json) => ResolvedLecture(
        classId: json['class_id'] as String,
        subjectId: json['subject_id'] as String,
        teacherId: json['teacher_id'] as String,
        roomNumber: json['room_number'] as String,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        status: json['status'] as String,
      );
}