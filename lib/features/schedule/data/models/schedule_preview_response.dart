import 'resolved_lecture.dart';

class SchedulePreviewResponse {
  final String date;
  final bool isHoliday;
  final List<ResolvedLecture> lectures;

  SchedulePreviewResponse({required this.date, required this.isHoliday, required this.lectures});

  factory SchedulePreviewResponse.fromJson(Map<String, dynamic> json) => SchedulePreviewResponse(
        date: json['date'] as String,
        isHoliday: json['is_holiday'] as bool,
        lectures: (json['lectures'] as List)
            .map((e) => ResolvedLecture.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}