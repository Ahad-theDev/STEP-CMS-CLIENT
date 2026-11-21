import 'package:cms/features/attendance/application/daily_attendance_repository_provider.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/exam_repository.dart';
import 'package:cms/features/exams/data/models/exam_marks_grid_model.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/exams/presentation/screens/exam_subjects_screen.dart';
import 'package:cms/features/exams/presentation/widgets/create_exam_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _schoolClass = SchoolClass(
  id: 'class-1',
  name: 'Class 1',
  section: 'A',
  academicYear: '2026-2027',
  isActive: true,
  createdAt: DateTime(2026),
);

class _Classes extends AllClassesController {
  @override
  Future<List<SchoolClass>> build() async => [_schoolClass];
}

class _Repository extends ExamRepository {
  _Repository() : super(Dio());

  @override
  Future<Exam> createExam(ExamCreateRequest request) async => Exam(
    id: 'exam-1',
    classId: request.classId,
    title: request.title,
    examType: request.examType,
    academicYear: request.academicYear,
    status: ExamStatus.draft,
    createdBy: 'user-1',
    createdAt: '2026-11-21',
    updatedAt: '2026-11-21',
  );

  @override
  Future<ExamMarksGrid> getExamDetails(String examId) async => ExamMarksGrid(
    examId: examId,
    examTitle: 'Term Exam',
    classId: 'class-1',
    examStatus: ExamStatus.draft,
    academicYear: '2026-2027',
    subjects: [],
    students: [],
  );
}

Future<void> _createExam(WidgetTester tester, {bool teacher = false}) async {
  await tester.binding.setSurfaceSize(const Size(1100, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        examRepositoryProvider.overrideWithValue(_Repository()),
        allClassesControllerProvider.overrideWith(_Classes.new),
        dailyAttendanceClassesProvider.overrideWith(
          (ref) async => [_schoolClass],
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => CreateExamDialog.show(
                context,
                preselectedClassId: 'class-1',
                preselectedClassName: 'Class 1',
                isTeacherMode: teacher,
              ),
              child: const Text('Open creation'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open creation'));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'Opening creation dialog');
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Exam Title *'),
    'Term Exam',
  );
  await tester.tap(find.text('Create Exam'));
  await tester.pumpAndSettle();
  expect(find.byType(CreateExamDialog), findsNothing);
  expect(find.text('Exam "Term Exam" created successfully!'), findsOneWidget);
}

void main() {
  for (final teacher in [false, true]) {
    testWidgets('exam success dismisses automatically for teacher=$teacher', (
      tester,
    ) async {
      await _createExam(tester, teacher: teacher);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('exam success can be closed immediately', (tester) async {
    await _createExam(tester);
    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('configure subjects works after creation dialog is disposed', (
    tester,
  ) async {
    await _createExam(tester);
    await tester.tap(find.text('Configure Subjects'));
    await tester.pumpAndSettle();
    final screen = tester.widget<ExamSubjectsScreen>(
      find.byType(ExamSubjectsScreen),
    );
    expect(screen.examId, 'exam-1');
    expect(screen.examTitle, 'Term Exam');
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
