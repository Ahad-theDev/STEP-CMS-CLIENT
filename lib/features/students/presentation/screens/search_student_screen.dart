import 'package:cms/features/students/data/models/student.dart';
import 'package:cms/features/students/presentation/widgets/student_search_section.dart';
import 'package:cms/features/students/presentation/screens/student_detail_screen.dart';
import 'package:flutter/material.dart';

class SearchStudentScreen extends StatefulWidget {
  const SearchStudentScreen({super.key});

  @override
  State<SearchStudentScreen> createState() => _SearchStudentScreenState();
}

class _SearchStudentScreenState extends State<SearchStudentScreen> {
  Future<void> _openStudentDetailScreen(Student student) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => StudentDetailScreen(student: student)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Students')),
      body: StudentSearchSection(
        onStudentTap: _openStudentDetailScreen,
      ),
    );
  }
}