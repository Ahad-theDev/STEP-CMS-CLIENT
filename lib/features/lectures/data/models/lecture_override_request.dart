import 'package:flutter/material.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';

enum LectureOverrideType { cancelled, rescheduled, substituteTeacher }

extension LectureOverrideTypeValue on LectureOverrideType {
  String get apiValue {
    switch (this) {
      case LectureOverrideType.cancelled:
        return 'cancelled';
      case LectureOverrideType.rescheduled:
        return 'rescheduled';
      case LectureOverrideType.substituteTeacher:
        return 'substitute_teacher';
    }
  }

  String get label {
    switch (this) {
      case LectureOverrideType.cancelled:
        return 'Cancel Lecture';
      case LectureOverrideType.rescheduled:
        return 'Reschedule';
      case LectureOverrideType.substituteTeacher:
        return 'Substitute Teacher';
    }
  }
}

class LectureOverrideRequest {
  final DateTime date;
  final LectureOverrideType overrideType;
  final String? teacherId;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? roomNumber;
  final String? reason;

  LectureOverrideRequest({
    required this.date,
    required this.overrideType,
    this.teacherId,
    this.startTime,
    this.endTime,
    this.roomNumber,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T').first,
        'override_type': overrideType.apiValue,
        if (teacherId != null) 'teacher_id': teacherId,
        if (startTime != null) 'start_time': TimeOfDayUtils.format(startTime!),
        if (endTime != null) 'end_time': TimeOfDayUtils.format(endTime!),
        if (roomNumber != null && roomNumber!.isNotEmpty) 'room_number': roomNumber,
        if (reason != null && reason!.isNotEmpty) 'reason': reason,
      };
}