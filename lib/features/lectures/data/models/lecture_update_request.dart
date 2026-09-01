import 'package:flutter/material.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';

class LectureUpdateRequest {
  final String? teacherId;
  final String? subjectId;
  final String? dayOfWeek;
  final String? roomNumber;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  LectureUpdateRequest({
    this.teacherId,
    this.subjectId,
    this.dayOfWeek,
    this.roomNumber,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() => {
        if (teacherId != null) 'teacher_id': teacherId,
        if (subjectId != null) 'subject_id': subjectId,
        if (dayOfWeek != null) 'day_of_week': dayOfWeek,
        if (roomNumber != null) 'room_number': roomNumber,
        if (startTime != null) 'start_time': TimeOfDayUtils.format(startTime!),
        if (endTime != null) 'end_time': TimeOfDayUtils.format(endTime!),
      };
}