import 'package:flutter/material.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';

class LectureCreateRequest {
  final String classId;
  final String teacherId;
  final String subjectId;
  final String dayOfWeek;
  final String roomNumber;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  LectureCreateRequest({
    required this.classId,
    required this.teacherId,
    required this.subjectId,
    required this.dayOfWeek,
    required this.roomNumber,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'teacher_id': teacherId,
        'subject_id': subjectId,
        'day_of_week': dayOfWeek,
        'room_number': roomNumber,
        'start_time': TimeOfDayUtils.format(startTime),
        'end_time': TimeOfDayUtils.format(endTime),
      };
}