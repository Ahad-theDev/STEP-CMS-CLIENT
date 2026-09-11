class AttendanceMarkResponse {
  final int marked;
  final List<String> skippedAlreadyMarked;

  AttendanceMarkResponse({required this.marked, required this.skippedAlreadyMarked});

  factory AttendanceMarkResponse.fromJson(Map<String, dynamic> json) => AttendanceMarkResponse(
        marked: json['marked'] as int,
        skippedAlreadyMarked: List<String>.from(json['skipped_already_marked'] ?? []),
      );
}