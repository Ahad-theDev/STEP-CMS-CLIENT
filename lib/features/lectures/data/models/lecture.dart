import 'package:freezed_annotation/freezed_annotation.dart';

part 'lecture.freezed.dart';
part 'lecture.g.dart';

@freezed
class Lecture with _$Lecture {
  const factory Lecture({
    required String id,
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'teacher_id') required String teacherId,
    @JsonKey(name: 'subject_id') required String subjectId,
    @JsonKey(name: 'room_number') required String roomNumber,
    @JsonKey(name: 'day_of_week') required String dayOfWeek,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(name: 'row_type') required String rowType,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Lecture;

  factory Lecture.fromJson(Map<String, dynamic> json) => _$LectureFromJson(json);
}