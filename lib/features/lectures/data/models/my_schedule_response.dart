class MyScheduleLecture {
  final String id;
  final String classId;
  final String subjectId;
  final String roomNumber;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int studentCount;

  MyScheduleLecture({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.roomNumber,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.studentCount,
  });

  factory MyScheduleLecture.fromJson(Map<String, dynamic> json) => MyScheduleLecture(
        id: json['id'] as String,
        classId: json['class_id'] as String,
        subjectId: json['subject_id'] as String,
        roomNumber: json['room_number'] as String,
        dayOfWeek: json['day_of_week'] as String,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        studentCount: json['student_count'] as int,
      );
}

class MyScheduleSummary {
  final int total;
  final int todayCount;

  MyScheduleSummary({required this.total, required this.todayCount});

  factory MyScheduleSummary.fromJson(Map<String, dynamic> json) => MyScheduleSummary(
        total: json['total'] as int,
        todayCount: json['today_count'] as int,
      );
}

class MyScheduleResponse {
  final List<MyScheduleLecture> lectures;
  final MyScheduleSummary summary;

  MyScheduleResponse({required this.lectures, required this.summary});

  factory MyScheduleResponse.fromJson(Map<String, dynamic> json) => MyScheduleResponse(
        lectures: (json['lectures'] as List)
            .map((e) => MyScheduleLecture.fromJson(e as Map<String, dynamic>))
            .toList(),
        summary: MyScheduleSummary.fromJson(json['summary'] as Map<String, dynamic>),
      );
}