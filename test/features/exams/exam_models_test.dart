import 'package:flutter_test/flutter_test.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/exams/data/models/exam_marks_grid_model.dart';
import 'package:cms/features/exams/data/models/bulk_marks_save_request.dart';
import 'package:cms/features/exams/data/models/exam_results_model.dart';
import 'package:cms/features/exams/data/models/exam_correction_model.dart';

void main() {
  group('Exam Models Test Suite', () {
    test('Exam and ExamListResponse parse backend response properly', () {
      final json = {
        'items': [
          {
            'id': 'exam-1',
            'class_id': 'class-1',
            'title': 'Mid Term Examination',
            'exam_type': 'mid_term',
            'academic_year': '2026-2027',
            'term_name': 'First Term',
            'exam_date': '2026-11-15',
            'description': 'Mid term exam description',
            'status': 'draft',
            'created_by': 'user-1',
            'published_at': null,
            'created_at': '2026-11-09T00:00:00Z',
            'updated_at': '2026-11-09T00:00:00Z',
            'student_count': 35,
            'class': {
              'id': 'class-1',
              'name': 'Class 5',
              'section': 'A',
            },
          }
        ],
        'page': 1,
        'limit': 20,
        'total': 1,
        'pages': 1,
      };

      final response = ExamListResponse.fromJson(json);
      expect(response.total, 1);
      expect(response.items.length, 1);

      final exam = response.items.first;
      expect(exam.id, 'exam-1');
      expect(exam.title, 'Mid Term Examination');
      expect(exam.examType, ExamType.midTerm);
      expect(exam.status, ExamStatus.draft);
      expect(exam.isDraft, isTrue);
      expect(exam.isPublished, isFalse);
      expect(exam.className, 'Class 5');
      expect(exam.section, 'A');
      expect(exam.studentCount, 35);
    });

    test('ExamCreateRequest serializes correct backend payload', () {
      const req = ExamCreateRequest(
        classId: 'class-1',
        title: ' Final Term ',
        examType: ExamType.finalTerm,
        academicYear: ' 2026-2027 ',
        termName: 'Term 2',
      );

      final json = req.toJson();
      expect(json['class_id'], 'class-1');
      expect(json['title'], 'Final Term');
      expect(json['exam_type'], 'final_term');
      expect(json['academic_year'], '2026-2027');
      expect(json['term_name'], 'Term 2');
    });

    test('ExamMarksGrid handles null marks vs zero marks correctly', () {
      final json = {
        'exam_id': 'exam-1',
        'exam_title': 'Mid Term',
        'class_id': 'class-1',
        'exam_status': 'draft',
        'academic_year': '2026-2027',
        'subjects': [
          {
            'id': 'sub-1',
            'exam_id': 'exam-1',
            'subject_name': 'English',
            'subject_code': 'ENG',
            'max_marks': 100,
            'passing_marks': 33,
            'display_order': 1,
          }
        ],
        'students': [
          {
            'student_id': 'stud-1',
            'student_name': 'Ali Ahmed',
            'roll_number': '001',
            'marks': [
              {
                'exam_subject_id': 'sub-1',
                'subject_name': 'English',
                'max_marks': 100,
                'passing_marks': 33,
                'marks_obtained': null,
                'is_absent': false,
              }
            ],
          },
          {
            'student_id': 'stud-2',
            'student_name': 'Sara Khan',
            'roll_number': '002',
            'marks': [
              {
                'exam_subject_id': 'sub-1',
                'subject_name': 'English',
                'max_marks': 100,
                'passing_marks': 33,
                'marks_obtained': 0.0,
                'is_absent': true,
                'remarks': 'Sick leave',
              }
            ],
          }
        ]
      };

      final grid = ExamMarksGrid.fromJson(json);
      expect(grid.subjects.length, 1);
      expect(grid.students.length, 2);

      final student1Mark = grid.students[0].marks[0];
      expect(student1Mark.marksObtained, isNull);
      expect(student1Mark.isAbsent, isFalse);
      expect(student1Mark.isEntered, isFalse);

      final student2Mark = grid.students[1].marks[0];
      expect(student2Mark.marksObtained, 0.0);
      expect(student2Mark.isAbsent, isTrue);
      expect(student2Mark.isEntered, isTrue);
      expect(student2Mark.remarks, 'Sick leave');
    });

    test('ExamMarksGrid handles Postgres string formatted decimals like "100.00"', () {
      final json = {
        'exam_id': 'b6773b45-34a9-4155-8206-fb6952c53824',
        'exam_title': 'Mid Term 2026-27',
        'class_id': 'd540d283-63cc-41bd-bcc6-62d0ea3b10c3',
        'exam_status': 'draft',
        'academic_year': '2026-2027',
        'subjects': [
          {
            'id': 'f9a60284-401e-4bcc-917d-c6360c52dade',
            'exam_id': 'b6773b45-34a9-4155-8206-fb6952c53824',
            'subject_name': 'English',
            'max_marks': '100.00',
            'passing_marks': '33.00',
            'display_order': 1,
          }
        ],
        'students': [
          {
            'student_id': 'bc421b5d-fe88-4771-9e3d-8b280b0dd2e6',
            'student_name': 'student 1',
            'roll_number': 'Two-1',
            'marks': [
              {
                'exam_subject_id': 'f9a60284-401e-4bcc-917d-c6360c52dade',
                'subject_name': 'English',
                'max_marks': '100.00',
                'passing_marks': '33.00',
                'marks_obtained': '85.50',
                'is_absent': false,
              }
            ],
          }
        ]
      };

      final grid = ExamMarksGrid.fromJson(json);
      expect(grid.subjects[0].maxMarks, 100.0);
      expect(grid.subjects[0].passingMarks, 33.0);
      expect(grid.students[0].marks[0].maxMarks, 100.0);
      expect(grid.students[0].marks[0].passingMarks, 33.0);
      expect(grid.students[0].marks[0].marksObtained, 85.5);
    });

    test('BulkExamMarksRequest serializes absent student as 0.0 marks', () {
      final req = BulkExamMarksRequest(
        entries: [
          const StudentMarksEntry(
            studentId: 'stud-1',
            marks: [
              StudentSubjectMarkEntry(
                examSubjectId: 'sub-1',
                marksObtained: 85.5,
                isAbsent: false,
              ),
              StudentSubjectMarkEntry(
                examSubjectId: 'sub-2',
                marksObtained: 50.0, // Should become 0.0 if absent
                isAbsent: true,
                remarks: 'Absent',
              ),
            ],
          ),
        ],
      );

      final json = req.toJson();
      final marks = (json['entries'] as List)[0]['marks'] as List;
      expect(marks[0]['marks_obtained'], 85.5);
      expect(marks[0]['is_absent'], isFalse);
      expect(marks[1]['marks_obtained'], 0.0);
      expect(marks[1]['is_absent'], isTrue);
    });

    test('ExamClassResults and StudentExamResult parse correctly', () {
      final json = {
        'student_id': 'stud-1',
        'student_name': 'Ali Ahmed',
        'roll_number': '001',
        'exam_id': 'exam-1',
        'exam_title': 'Mid Term',
        'exam_status': 'published',
        'subject_results': [
          {
            'exam_subject_id': 'sub-1',
            'subject_name': 'English',
            'max_marks': 100,
            'passing_marks': 33,
            'marks_obtained': 75.0,
            'is_absent': false,
          }
        ],
        'total_obtained': 75.0,
        'total_maximum': 100.0,
        'percentage': 75.0,
      };

      final res = StudentExamResult.fromJson(json);
      expect(res.studentName, 'Ali Ahmed');
      expect(res.totalObtained, 75.0);
      expect(res.percentage, 75.0);
      expect(res.subjectResults.length, 1);
    });

    test('ExamResultCorrection and Audit parse correctly', () {
      const correction = ExamResultCorrection(
        marksObtained: 82.5,
        reason: 'Recounting requested',
      );
      final cJson = correction.toJson();
      expect(cJson['marks_obtained'], 82.5);
      expect(cJson['reason'], 'Recounting requested');

      final auditJson = {
        'id': 'audit-1',
        'student_result_id': 'res-1',
        'old_marks': 75.0,
        'new_marks': 82.5,
        'old_is_absent': false,
        'new_is_absent': false,
        'changed_by': 'user-1',
        'reason': 'Recounting requested',
        'changed_at': '2026-11-09T10:00:00Z',
      };
      final audit = ExamResultAudit.fromJson(auditJson);
      expect(audit.oldMarks, 75.0);
      expect(audit.newMarks, 82.5);
      expect(audit.reason, 'Recounting requested');
    });
  });
}
