import 'package:flutter/material.dart';
import '../widgets/student_action_cards_row.dart';
import '../widgets/student_search_section.dart';
import 'add_student_screen.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final _searchSectionKey = GlobalKey<StudentSearchSectionState>();

  Future<void> _openAddStudent() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddStudentScreen()),
    );
    if (created == true) {
      _searchSectionKey.currentState?.refreshIfClassSelected();
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature — coming soon')));
  }

  void _scrollToSearch() {
    final ctx = _searchSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudentActionCardsRow(
              onCreate: _openAddStudent,
              onUpdate: () => _showComingSoon('Update Student'),
              onChangeEnrollment: () => _showComingSoon('Change Enrollment'),
              onDelete: () => _showComingSoon('Delete Student'),
              onSearch: _scrollToSearch,
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
            StudentSearchSection(key: _searchSectionKey),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}