double _parseDecimalString(dynamic value) {
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}

class FeeSummaryTotals {
  final double totalDue;
  final double totalCollected;
  final double collectionEfficiency;
  final int studentsPaid;
  final int studentsPartial;
  final int studentsUnpaid;

  FeeSummaryTotals({
    required this.totalDue,
    required this.totalCollected,
    required this.collectionEfficiency,
    required this.studentsPaid,
    required this.studentsPartial,
    required this.studentsUnpaid,
  });

  factory FeeSummaryTotals.fromJson(Map<String, dynamic> json) => FeeSummaryTotals(
        totalDue: _parseDecimalString(json['total_due']),
        totalCollected: _parseDecimalString(json['total_collected']),
        collectionEfficiency: (json['collection_efficiency'] as num).toDouble(),
        studentsPaid: json['students_paid'] as int,
        studentsPartial: json['students_partial'] as int,
        studentsUnpaid: json['students_unpaid'] as int,
      );
}

class FeeSummaryBreakdownItem {
  final String classId;
  final double due;
  final double collected;
  final double efficiency;

  FeeSummaryBreakdownItem({
    required this.classId,
    required this.due,
    required this.collected,
    required this.efficiency,
  });

  factory FeeSummaryBreakdownItem.fromJson(Map<String, dynamic> json) => FeeSummaryBreakdownItem(
        classId: json['class_id'] as String,
        due: _parseDecimalString(json['due']),
        collected: _parseDecimalString(json['collected']),
        efficiency: (json['efficiency'] as num).toDouble(),
      );
}

class FeeSummaryResponse {
  final FeeSummaryTotals summary;
  final List<FeeSummaryBreakdownItem> breakdown;

  FeeSummaryResponse({required this.summary, required this.breakdown});

  factory FeeSummaryResponse.fromJson(Map<String, dynamic> json) => FeeSummaryResponse(
        summary: FeeSummaryTotals.fromJson(json['summary'] as Map<String, dynamic>),
        breakdown: (json['breakdown'] as List)
            .map((e) => FeeSummaryBreakdownItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}