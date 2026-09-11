class TrendPoint {
  final String date;
  final int present;
  final int absent;
  final int late;
  final int leave;
  final double percentage;

  TrendPoint({
    required this.date,
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.percentage,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
        date: json['date'] as String,
        present: json['present'] as int,
        absent: json['absent'] as int,
        late: json['late'] as int,
        leave: json['leave'] as int,
        percentage: (json['percentage'] as num).toDouble(),
      );
}