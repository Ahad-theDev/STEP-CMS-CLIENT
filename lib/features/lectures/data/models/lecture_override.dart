class LectureOverride {
  final String id;
  final String overridesLectureId;
  final String date;
  final String overrideType;
  final String teacherId;
  final String roomNumber;
  final String startTime;
  final String endTime;
  final String? reason;

  LectureOverride({
    required this.id,
    required this.overridesLectureId,
    required this.date,
    required this.overrideType,
    required this.teacherId,
    required this.roomNumber,
    required this.startTime,
    required this.endTime,
    this.reason,
  });

  factory LectureOverride.fromJson(Map<String, dynamic> json) => LectureOverride(
        id: json['id'] as String,
        overridesLectureId: json['overrides_lecture_id'] as String,
        date: json['date'] as String,
        overrideType: json['override_type'] as String,
        teacherId: json['teacher_id'] as String,
        roomNumber: json['room_number'] as String,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        reason: json['reason'] as String?,
      );
}