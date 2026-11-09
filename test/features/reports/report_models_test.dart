import 'package:flutter_test/flutter_test.dart';
import 'package:cms/features/reports/data/models/daily_attendance_report_model.dart';
import 'package:cms/features/reports/data/models/lecture_attendance_report_model.dart';
import 'package:cms/features/reports/data/models/fee_report_model.dart';
import 'package:cms/features/reports/data/models/marks_report_model.dart';

void main() {
  group('Report Models Test Suite', () {
    test('DailyAttendanceReport parses backend json correctly', () {
      final json = {
        'meta': {
          'report_type': 'daily_attendance',
          'scope': 'class',
          'generated_at': '2026-01-31T10:00:00Z',
          'filters': {'class_id': 'class-1'},
        },
        'summary': {
          'days_recorded': 20,
          'present': 18,
          'late': 1,
          'absent': 1,
          'leave': 0,
          'short_leave': 0,
          'unfinalized': 0,
          'attendance_percentage': 90.0,
          'unique_attendance_dates': 20,
        },
        'students': [
          {
            'student_id': 'stud-1',
            'student_name': 'Ali Ahmed',
            'roll_number': '01',
            'days_recorded': 20,
            'present_days': 18,
            'late_days': 1,
            'absent_days': 1,
            'leave_days': 0,
            'short_leave_days': 0,
            'unfinalized_days': 0,
            'attendance_percentage': 90.0,
          }
        ],
        'records': [
          {
            'student_id': 'stud-1',
            'student_name': 'Ali Ahmed',
            'roll_number': '01',
            'class_id': 'class-1',
            'attendance_date': '2026-01-01',
            'morning_status': 'present',
            'closing_status': 'present',
            'final_status': 'present',
            'remarks': 'On time',
          }
        ]
      };

      final report = DailyAttendanceReport.fromJson(json);
      expect(report.meta.reportType, 'daily_attendance');
      expect(report.summary.daysRecorded, 20);
      expect(report.summary.attendancePercentage, 90.0);
      expect(report.students.length, 1);
      expect(report.students[0].studentName, 'Ali Ahmed');
      expect(report.records.length, 1);
      expect(report.records[0].finalStatus, 'present');
    });

    test('LectureAttendanceReport parses backend json correctly', () {
      final json = {
        'meta': {
          'report_type': 'lecture_attendance',
          'scope': 'class',
          'generated_at': '2026-01-31T10:00:00Z',
          'filters': {},
        },
        'summary': {
          'present': 50,
          'late': 5,
          'absent': 5,
          'leave': 0,
          'attendance_entries': 60,
          'attended_lectures': 55,
          'attendance_percentage': 91.67,
          'scheduled_lecture_slots': 60,
        },
        'students': [
          {
            'student_id': 'stud-1',
            'student_name': 'Sara Khan',
            'roll_number': '02',
            'present_count': 25,
            'late_count': 3,
            'absent_count': 2,
            'leave_count': 0,
            'marked_lectures': 30,
            'attended_lectures': 28,
            'total_lectures': 30,
            'attendance_percentage': 93.33,
          }
        ],
        'records': []
      };

      final report = LectureAttendanceReport.fromJson(json);
      expect(report.summary.attendancePercentage, 91.67);
      expect(report.summary.attendedLectures, 55);
      expect(report.students.first.studentName, 'Sara Khan');
      expect(report.students.first.attendancePercentage, 93.33);
    });

    test('FeeReport parses backend json correctly', () {
      final json = {
        'meta': {
          'report_type': 'fees',
          'scope': 'class',
          'generated_at': '2026-03-31T10:00:00Z',
          'filters': {},
        },
        'summary': {
          'total_fee_due': 50000.0,
          'total_fee_submitted': 42000.0,
          'outstanding_fee': 8000.0,
          'fee_records': 10,
          'paid_records': 6,
          'partial_records': 2,
          'unpaid_records': 2,
          'students_with_fee_records': 10,
          'students_in_report': 12,
          'collection_percentage': 84.0,
        },
        'students': [
          {
            'student_id': 'stud-1',
            'student_name': 'Ali Ahmed',
            'roll_number': '01',
            'total_fee_due': 10000.0,
            'total_fee_submitted': 8000.0,
            'outstanding_fee': 2000.0,
            'paid_records': 1,
            'partial_records': 1,
            'unpaid_records': 0,
            'fee_records': [
              {
                'fee_record_id': 'fee-1',
                'class_id': 'class-1',
                'month': 1,
                'year': 2026,
                'amount_due': 5000.0,
                'amount_paid': 3000.0,
                'outstanding': 2000.0,
                'status': 'partial',
                'payment_date': '2026-01-10',
              }
            ],
          }
        ]
      };

      final report = FeeReport.fromJson(json);
      expect(report.summary.totalFeeDue, 50000.0);
      expect(report.summary.collectionPercentage, 84.0);
      expect(report.students.length, 1);
      expect(report.students[0].feeRecords.length, 1);
      expect(report.students[0].feeRecords[0].status, 'partial');
    });

    test('MarksReport parses backend json correctly', () {
      final json = {
        'meta': {
          'report_type': 'marks',
          'scope': 'class',
          'generated_at': '2026-01-31T10:00:00Z',
          'filters': {},
        },
        'exam': {
          'exam_id': 'exam-1',
          'title': 'Mid Term',
          'exam_type': 'mid_term',
          'academic_year': '2025-2026',
          'term_name': 'Term 1',
          'exam_date': '2026-01-20',
          'published_at': '2026-01-25T10:00:00Z',
        },
        'summary': {
          'students_count': 30,
          'total_obtained_marks': 2200.0,
          'total_maximum_marks': 3000.0,
          'average_percentage': 73.33,
          'maximum_marks_per_student': 100.0,
        },
        'subjects': [
          {
            'exam_subject_id': 'sub-1',
            'subject_name': 'English',
            'max_marks_per_student': 100.0,
            'class_maximum_marks': 3000.0,
            'class_obtained_marks': 2200.0,
            'students_marked': 30,
          }
        ],
        'students': [
          {
            'student_id': 'stud-1',
            'student_name': 'Sara',
            'roll_number': '01',
            'total_obtained': 75.0,
            'total_maximum': 100.0,
            'percentage': 75.0,
            'subject_results': [
              {
                'exam_subject_id': 'sub-1',
                'subject_name': 'English',
                'max_marks': 100.0,
                'passing_marks': 33.0,
                'marks_obtained': 75.0,
                'is_absent': false,
                'is_passed': true,
              }
            ],
          }
        ]
      };

      final report = MarksReport.fromJson(json);
      expect(report.exam.title, 'Mid Term');
      expect(report.summary.studentsCount, 30);
      expect(report.subjects.length, 1);
      expect(report.students.length, 1);
      expect(report.students[0].subjectResults[0].isPassed, isTrue);
    });
  });
}
