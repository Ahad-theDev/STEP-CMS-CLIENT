import 'package:flutter_test/flutter_test.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/exams/data/models/exam_marks_grid_model.dart';
import 'package:cms/features/exams/data/models/exam_results_model.dart';
import 'package:cms/features/exams/data/models/exam_subject_model.dart';
import 'package:cms/features/reports/data/models/daily_attendance_report_model.dart';
import 'package:cms/features/reports/data/models/lecture_attendance_report_model.dart';
import 'package:cms/features/reports/data/models/fee_report_model.dart';
import 'package:cms/features/reports/data/models/marks_report_model.dart';
import 'package:cms/features/reports/services/report_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReportPdfService PDF Generation Test Suite', () {
    final pdfService = ReportPdfService.instance;

    test('calculateGrade assigns correct academic grades', () {
      expect(pdfService.calculateGrade(95.0), 'A+');
      expect(pdfService.calculateGrade(80.0), 'A+');
      expect(pdfService.calculateGrade(75.0), 'A');
      expect(pdfService.calculateGrade(65.0), 'B');
      expect(pdfService.calculateGrade(55.0), 'C');
      expect(pdfService.calculateGrade(40.0), 'D');
      expect(pdfService.calculateGrade(32.9), 'F');
    });

    test('generateDailyAttendancePdf produces valid PDF bytes', () async {
      final report = DailyAttendanceReport(
        meta: const ReportMeta(
          reportType: 'daily_attendance',
          scope: 'class',
          generatedAt: '2026-01-31T10:00:00Z',
          filters: {},
        ),
        summary: const DailyAttendanceSummary(
          daysRecorded: 22,
          present: 20,
          late: 1,
          absent: 1,
          leave: 0,
          shortLeave: 0,
          unfinalized: 0,
          attendancePercentage: 90.9,
          uniqueAttendanceDates: 22,
        ),
        students: [
          const DailyAttendanceStudentRow(
            studentId: 'stud-1',
            studentName: 'Ali Ahmed',
            rollNumber: '01',
            daysRecorded: 22,
            presentDays: 20,
            lateDays: 1,
            absentDays: 1,
            leaveDays: 0,
            shortLeaveDays: 0,
            unfinalizedDays: 0,
            attendancePercentage: 90.9,
          ),
        ],
        records: const [],
      );

      final bytes = await pdfService.generateDailyAttendancePdf(report);
      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      // Valid PDF files start with %PDF
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('generateLectureAttendancePdf produces valid PDF bytes', () async {
      final report = LectureAttendanceReport(
        meta: const ReportMeta(
          reportType: 'lecture_attendance',
          scope: 'class',
          generatedAt: '2026-01-31T10:00:00Z',
          filters: {},
        ),
        summary: const LectureAttendanceSummary(
          present: 45,
          late: 3,
          absent: 2,
          leave: 0,
          attendanceEntries: 50,
          attendedLectures: 48,
          attendancePercentage: 96.0,
          scheduledLectureSlots: 50,
        ),
        students: [
          const LectureAttendanceStudentRow(
            studentId: 'stud-1',
            studentName: 'Sara Khan',
            rollNumber: '02',
            presentCount: 24,
            lateCount: 1,
            absentCount: 0,
            leaveCount: 0,
            markedLectures: 25,
            attendedLectures: 25,
            totalLectures: 25,
            attendancePercentage: 100.0,
          ),
        ],
        records: const [],
      );

      final bytes = await pdfService.generateLectureAttendancePdf(report);
      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('generateFeePdf produces valid PDF bytes', () async {
      final report = FeeReport(
        meta: const ReportMeta(
          reportType: 'fees',
          scope: 'class',
          generatedAt: '2026-01-31T10:00:00Z',
          filters: {},
        ),
        summary: const FeeReportSummary(
          totalFeeDue: 100000.0,
          totalFeeSubmitted: 85000.0,
          outstandingFee: 15000.0,
          feeRecords: 20,
          paidRecords: 17,
          partialRecords: 2,
          unpaidRecords: 1,
          studentsWithFeeRecords: 20,
          studentsInReport: 20,
          collectionPercentage: 85.0,
        ),
        students: [
          const FeeReportStudent(
            studentId: 'stud-1',
            studentName: 'Ali Ahmed',
            rollNumber: '01',
            totalFeeDue: 5000.0,
            totalFeeSubmitted: 5000.0,
            outstandingFee: 0.0,
            paidRecords: 1,
            partialRecords: 0,
            unpaidRecords: 0,
            feeRecords: [],
          ),
        ],
      );

      final bytes = await pdfService.generateFeePdf(report);
      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('generateMarksPdf produces valid PDF bytes', () async {
      final report = MarksReport(
        meta: const ReportMeta(
          reportType: 'marks',
          scope: 'class',
          generatedAt: '2026-01-31T10:00:00Z',
          filters: {},
        ),
        exam: const MarksReportExamMeta(
          examId: 'exam-1',
          title: 'Mid Term 2026-27',
          examType: 'mid_term',
          academicYear: '2026-2027',
        ),
        summary: const MarksReportSummary(
          studentsCount: 1,
          totalObtainedMarks: 85.0,
          totalMaximumMarks: 100.0,
          averagePercentage: 85.0,
          maximumMarksPerStudent: 100.0,
        ),
        subjects: [
          const MarksReportSubjectSummary(
            examSubjectId: 'sub-1',
            subjectName: 'English',
            maxMarksPerStudent: 100.0,
            classMaximumMarks: 100.0,
            classObtainedMarks: 85.0,
            studentsMarked: 1,
          ),
        ],
        students: [
          const MarksReportStudent(
            studentId: 'stud-1',
            studentName: 'Ali Ahmed',
            rollNumber: '01',
            totalObtained: 85.0,
            totalMaximum: 100.0,
            percentage: 85.0,
            subjectResults: [
              MarksSubjectResultItem(
                examSubjectId: 'sub-1',
                subjectName: 'English',
                maxMarks: 100.0,
                passingMarks: 33.0,
                marksObtained: 85.0,
                isAbsent: false,
                isPassed: true,
              ),
            ],
          ),
        ],
      );

      final bytes = await pdfService.generateMarksPdf(report);
      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('generateClassResultsPdf produces valid PDF bytes for teachers & management', () async {
      const results = ExamClassResults(
        examId: 'exam-1',
        examTitle: 'Mid Term 2026-27',
        classId: 'class-1',
        examStatus: ExamStatus.published,
        academicYear: '2026-2027',
        subjects: [
          ExamSubject(
            id: 'sub-1',
            examId: 'exam-1',
            subjectName: 'English',
            maxMarks: 100.0,
            passingMarks: 33.0,
            displayOrder: 1,
          ),
        ],
        students: [
          ExamClassResultStudent(
            studentId: 'stud-1',
            studentName: 'Ali Ahmed',
            rollNumber: '01',
            subjectResults: [
              GridMark(
                examSubjectId: 'sub-1',
                subjectName: 'English',
                maxMarks: 100.0,
                passingMarks: 33.0,
                marksObtained: 88.0,
                isAbsent: false,
              ),
            ],
            totalObtained: 88.0,
            totalMaximum: 100.0,
            percentage: 88.0,
          ),
        ],
      );

      final bytes = await pdfService.generateClassResultsPdf(results);
      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('generateStudentReportCardPdf generates official student report card PDF', () async {
      const studentResult = StudentExamResult(
        studentId: 'stud-1',
        studentName: 'Sara Khan',
        rollNumber: 'Two-05',
        examId: 'exam-1',
        examTitle: 'Mid Term Examination',
        examStatus: ExamStatus.published,
        subjectResults: [
          GridMark(
            examSubjectId: 'sub-1',
            subjectName: 'English',
            maxMarks: 100.0,
            passingMarks: 33.0,
            marksObtained: 92.5,
            isAbsent: false,
            remarks: 'Excellent comprehension',
          ),
          GridMark(
            examSubjectId: 'sub-2',
            subjectName: 'Mathematics',
            maxMarks: 100.0,
            passingMarks: 33.0,
            marksObtained: 84.0,
            isAbsent: false,
            remarks: 'Strong problem solving',
          ),
        ],
        totalObtained: 176.5,
        totalMaximum: 200.0,
        percentage: 88.25,
      );

      final bytes = await pdfService.generateStudentReportCardPdf(
        studentResult,
        className: 'Class 5-A',
        academicYear: '2026-2027',
      );
      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
