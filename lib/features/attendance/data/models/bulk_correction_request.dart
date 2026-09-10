class AttendanceCorrectionEntryRequest {
  final String studentId;
  final String status;
  final String reason;
  final String action; // 'correct' | 'add'

  AttendanceCorrectionEntryRequest({
    required this.studentId,
    required this.status,
    required this.reason,
    required this.action,
  });

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'status': status,
        'reason': reason,
        'action': action,
      };
}

class BulkCorrectionRequest {
  final String lectureId;
  final DateTime date;
  final List<AttendanceCorrectionEntryRequest> corrections;

  BulkCorrectionRequest({required this.lectureId, required this.date, required this.corrections});

  Map<String, dynamic> toJson() => {
        'lecture_id': lectureId,
        'date': date.toIso8601String().split('T').first,
        'corrections': corrections.map((c) => c.toJson()).toList(),
      };
}