class DefaulterEntry {
  final String studentId;
  final String studentName;
  final double percentagePresent;
  final int totalLectures;

  DefaulterEntry({
    required this.studentId,
    required this.studentName,
    required this.percentagePresent,
    required this.totalLectures,
  });

  factory DefaulterEntry.fromJson(Map<String, dynamic> json) => DefaulterEntry(
        studentId: json['student_id'] as String,
        studentName: json['student_name'] as String,
        percentagePresent: (json['percentage_present'] as num).toDouble(),
        totalLectures: json['total_lectures'] as int,
      );
}

class DefaultersResponse {
  final double threshold;
  final String? dateFrom;
  final String? dateTo;
  final List<DefaulterEntry> defaulters;

  DefaultersResponse({
    required this.threshold,
    this.dateFrom,
    this.dateTo,
    required this.defaulters,
  });

  factory DefaultersResponse.fromJson(Map<String, dynamic> json) => DefaultersResponse(
        threshold: (json['threshold'] as num).toDouble(),
        dateFrom: json['date_from'] as String?,
        dateTo: json['date_to'] as String?,
        defaulters: (json['defaulters'] as List)
            .map((e) => DefaulterEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}