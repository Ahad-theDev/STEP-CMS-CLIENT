import 'package:flutter_test/flutter_test.dart';
import 'package:cms/features/attendance/data/models/student_daily_attendance_roster.dart';
import 'package:cms/features/attendance/data/models/morning_attendance_request.dart';
import 'package:cms/features/attendance/data/models/closing_attendance_request.dart';
import 'package:cms/features/attendance/data/models/daily_attendance_correction_request.dart';
import 'package:cms/features/attendance/data/models/daily_attendance_mark_result.dart';

void main() {
  group('Daily Attendance Models Test', () {
    test('DailyClassRoster and DailyRosterStudent parse backend roster json', () {
      final json = {
        'class_id': '8665ba4f-1234-4567-89ab-cdef01234567',
        'attendance_date': '2026-11-08',
        'students': [
          {
            'student_id': '11111111-1111-1111-1111-111111111111',
            'student_name': 'Ahmad Ali',
            'roll_number': '101',
            'morning_status': 'present',
            'closing_status': 'present',
            'final_status': 'present',
            'remarks': 'On time',
          },
          {
            'student_id': '22222222-2222-2222-2222-222222222222',
            'student_name': 'Fatima Noor',
            'roll_number': '102',
            'morning_status': 'present',
            'closing_status': 'absent',
            'final_status': 'short_leave',
            'remarks': 'Left after lunch with slip',
          },
          {
            'student_id': '33333333-3333-3333-3333-333333333333',
            'student_name': 'Bilal Khan',
            'roll_number': '103',
            'morning_status': null,
            'closing_status': null,
            'final_status': null,
            'remarks': null,
          },
        ],
      };

      final roster = DailyClassRoster.fromJson(json);

      expect(roster.classId, '8665ba4f-1234-4567-89ab-cdef01234567');
      expect(roster.attendanceDate, '2026-11-08');
      expect(roster.students.length, 3);

      final s1 = roster.students[0];
      expect(s1.studentName, 'Ahmad Ali');
      expect(s1.morningStatus, 'present');
      expect(s1.closingStatus, 'present');
      expect(s1.finalStatus, 'present');
      expect(s1.remarks, 'On time');

      final s2 = roster.students[1];
      expect(s2.studentName, 'Fatima Noor');
      expect(s2.morningStatus, 'present');
      expect(s2.closingStatus, 'absent');
      expect(s2.finalStatus, 'short_leave');

      final s3 = roster.students[2];
      expect(s3.studentName, 'Bilal Khan');
      expect(s3.morningStatus, isNull);
      expect(s3.closingStatus, isNull);
      expect(s3.finalStatus, isNull);

      // Verify copyWith works
      final updatedS3 = s3.copyWith(morningStatus: 'late', remarks: 'Bus late');
      expect(updatedS3.morningStatus, 'late');
      expect(updatedS3.remarks, 'Bus late');
      expect(updatedS3.studentName, 'Bilal Khan');
    });

    test('MorningAttendanceRequest serializes correct JSON structure', () {
      final request = MorningAttendanceRequest(
        attendanceDate: '2026-11-08',
        entries: [
          const MorningAttendanceEntry(
            studentId: '11111111-1111-1111-1111-111111111111',
            status: 'present',
          ),
          const MorningAttendanceEntry(
            studentId: '22222222-2222-2222-2222-222222222222',
            status: 'late',
            remarks: 'Traffic issue',
          ),
        ],
      );

      final json = request.toJson();
      expect(json['attendance_date'], '2026-11-08');
      final entries = json['entries'] as List;
      expect(entries.length, 2);
      expect(entries[0]['student_id'], '11111111-1111-1111-1111-111111111111');
      expect(entries[0]['status'], 'present');
      expect(entries[0]['remarks'], isNull);

      expect(entries[1]['student_id'], '22222222-2222-2222-2222-222222222222');
      expect(entries[1]['status'], 'late');
      expect(entries[1]['remarks'], 'Traffic issue');
    });

    test('ClosingAttendanceRequest serializes correct JSON structure', () {
      final request = ClosingAttendanceRequest(
        attendanceDate: '2026-11-08',
        entries: [
          const ClosingAttendanceEntry(
            studentId: '11111111-1111-1111-1111-111111111111',
            status: 'present',
          ),
          const ClosingAttendanceEntry(
            studentId: '22222222-2222-2222-2222-222222222222',
            status: 'absent',
            remarks: 'Left at 12:30pm',
          ),
        ],
      );

      final json = request.toJson();
      expect(json['attendance_date'], '2026-11-08');
      final entries = json['entries'] as List;
      expect(entries.length, 2);
      expect(entries[0]['status'], 'present');
      expect(entries[1]['status'], 'absent');
      expect(entries[1]['remarks'], 'Left at 12:30pm');
    });

    test('DailyAttendanceCorrectionRequest serializes with mandatory reason', () {
      final request = DailyAttendanceCorrectionRequest(
        attendanceDate: '2026-11-08',
        morningStatus: 'present',
        closingStatus: 'present',
        remarks: 'Corrected per parent notice',
        reason: 'Parent provided verified doctor certificate',
      );

      final json = request.toJson();
      expect(json['attendance_date'], '2026-11-08');
      expect(json['morning_status'], 'present');
      expect(json['closing_status'], 'present');
      expect(json['remarks'], 'Corrected per parent notice');
      expect(json['reason'], 'Parent provided verified doctor certificate');
    });

    test('DailyAttendanceMarkResult parses backend response', () {
      final json = {
        'message': 'Morning attendance saved successfully',
        'created': 25,
        'updated': 0,
      };

      final result = DailyAttendanceMarkResult.fromJson(json);
      expect(result.message, 'Morning attendance saved successfully');
      expect(result.created, 25);
      expect(result.updated, 0);
    });
  });
}
