import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/delete_student_controller.dart';
import '../../data/models/student.dart';
import '../widgets/student_action_cards_row.dart';
import '../widgets/student_search_section.dart';
import 'add_student_screen.dart';
import 'select_student_screen.dart';
import 'update_student_screen.dart';
import 'change_enrollment_screen.dart';

class StudentManagementScreen extends ConsumerStatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  ConsumerState<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends ConsumerState<StudentManagementScreen> {
  final _searchSectionKey = GlobalKey<StudentSearchSectionState>();

  Future<void> _openAddStudent() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddStudentScreen()),
    );
    if (created == true) {
      _searchSectionKey.currentState?.refreshIfClassSelected();
    }
  }

  Future<void> _openUpdateStudent() async {
    final selected = await Navigator.of(context).push<Student>(
      MaterialPageRoute(builder: (_) => const SelectStudentScreen(title: 'Select Student to Update')),
    );
    if (selected == null || !mounted) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UpdateStudentScreen(student: selected)),
    );
    if (updated == true) {
      _searchSectionKey.currentState?.refreshIfClassSelected();
    }
  }

  Future<void> _openChangeEnrollment() async {
    final selected = await Navigator.of(context).push<Student>(
      MaterialPageRoute(builder: (_) => const SelectStudentScreen(title: 'Select Student to Move')),
    );
    if (selected == null || !mounted) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ChangeEnrollmentScreen(student: selected)),
    );
    if (changed == true) {
      _searchSectionKey.currentState?.refreshIfClassSelected();
    }
  }

  Future<void> _openDeleteStudent() async {
    final selected = await Navigator.of(context).push<Student>(
      MaterialPageRoute(builder: (_) => const SelectStudentScreen(title: 'Select Student to Delete')),
    );
    if (selected == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
          'Deactivate ${selected.fullName} (Roll #${selected.rollNumber})? '
          'This cannot be undone from the app.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await ref.read(deleteStudentControllerProvider.notifier).deleteStudent(selected.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deactivated')));
      _searchSectionKey.currentState?.refreshIfClassSelected();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete student')));
    }
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
              onUpdate: _openUpdateStudent,
              onChangeEnrollment: _openChangeEnrollment,
              onDelete: _openDeleteStudent,
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