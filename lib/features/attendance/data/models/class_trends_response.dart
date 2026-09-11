import 'trend_point.dart';

class ClassTrendsResponse {
  final String classId;
  final String dateFrom;
  final String dateTo;
  final List<TrendPoint> trends;

  ClassTrendsResponse({
    required this.classId,
    required this.dateFrom,
    required this.dateTo,
    required this.trends,
  });

  factory ClassTrendsResponse.fromJson(Map<String, dynamic> json) => ClassTrendsResponse(
        classId: json['class_id'] as String,
        dateFrom: json['date_from'] as String,
        dateTo: json['date_to'] as String,
        trends: (json['trends'] as List)
            .map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}