import 'trend_point.dart';

class TeacherClassTrend {
  final String classId;
  final List<TrendPoint> trends;

  TeacherClassTrend({required this.classId, required this.trends});

  factory TeacherClassTrend.fromJson(Map<String, dynamic> json) => TeacherClassTrend(
        classId: json['class_id'] as String,
        trends: (json['trends'] as List)
            .map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TeacherTrendsResponse {
  final String teacherId;
  final String dateFrom;
  final String dateTo;
  final List<TeacherClassTrend> classes;

  TeacherTrendsResponse({
    required this.teacherId,
    required this.dateFrom,
    required this.dateTo,
    required this.classes,
  });

  factory TeacherTrendsResponse.fromJson(Map<String, dynamic> json) => TeacherTrendsResponse(
        teacherId: json['teacher_id'] as String,
        dateFrom: json['date_from'] as String,
        dateTo: json['date_to'] as String,
        classes: (json['classes'] as List)
            .map((e) => TeacherClassTrend.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}