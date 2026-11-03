import 'package:cms/features/students/data/models/student.dart';
import 'package:cms/features/students/presentation/screens/select_student_screen.dart';
import 'package:cms/features/students/presentation/screens/student_detail_screen.dart';
import 'package:flutter/material.dart';

class SearchStudentScreen extends StatelessWidget {
  const SearchStudentScreen({super.key});

  Future<void> _openStudentDetailScreen(BuildContext context, Student student) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => StudentDetailScreen(student: student)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectStudentScreen(
      title: 'Search Students',
      onStudentTap: (student) => _openStudentDetailScreen(context, student),
    );
  }
}
