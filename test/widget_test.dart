// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cms/features/auth/presentation/screens/register_screen.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';
import 'package:cms/features/subjects/data/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestSubjects extends SubjectsListController {
  @override
  Future<List<Subject>> build() async => [
    Subject(
      id: 'math',
      name: 'Mathematics',
      code: 'MATH',
      isActive: true,
      createdAt: DateTime(2026),
    ),
  ];
}

void main() {
  testWidgets('Register screen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subjectsListControllerProvider.overrideWith(_TestSubjects.new),
        ],
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the register screen renders with the correct title.
    expect(find.text('Add New User'), findsOneWidget);
    expect(
      find.text('Fill in the details below to create a new campus account.'),
      findsOneWidget,
    );

    // Verify all form fields are present.
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Role'), findsOneWidget);
    expect(find.text('Subject specialization'), findsOneWidget);

    // Verify the submit button is present (ElevatedButton with Create User text).
    expect(find.widgetWithText(ElevatedButton, 'Create User'), findsOneWidget);
  });
}
