import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/delete_teacher_controller.dart';
import '../../application/teachers_list_controller.dart';
import '../../data/models/teacher.dart';
import '../widgets/teacher_action_cards_row.dart';
import '../widgets/teacher_search_section.dart';
import 'select_teacher_screen.dart';
import 'update_teacher_screen.dart';
import 'search_teachers_screen.dart';
import 'bulk_import_teachers_screen.dart';
import 'package:cms/features/auth/presentation/screens/register_screen.dart';

class TeacherManagementScreen extends ConsumerStatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  ConsumerState<TeacherManagementScreen> createState() => _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends ConsumerState<TeacherManagementScreen> {
  final _searchSectionKey = GlobalKey<TeacherSearchSectionState>();

  Future<void> _refreshList() async {
    ref.invalidate(teachersListControllerProvider);
    _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openUpdateTeacher() async {
    final selected = await Navigator.of(context).push<Teacher>(
      MaterialPageRoute(builder: (_) => const SelectTeacherScreen(title: 'Select Teacher to Update')),
    );
    if (selected == null || !mounted) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UpdateTeacherScreen(teacher: selected)),
    );
    if (updated == true) {
      ref.invalidate(teachersListControllerProvider);
      _searchSectionKey.currentState?.refresh();
    }
  }

  Future<void> _openDeleteTeacher() async {
    final selected = await Navigator.of(context).push<Teacher>(
      MaterialPageRoute(builder: (_) => const SelectTeacherScreen(title: 'Select Teacher to Delete')),
    );
    if (selected == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Deactivate ${selected.fullName}? This cannot be undone from the app.'),
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

    final success = await ref.read(deleteTeacherControllerProvider.notifier).deleteTeacher(selected.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teacher deactivated')));
      ref.invalidate(teachersListControllerProvider);
      _searchSectionKey.currentState?.refresh();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to delete teacher')));
    }
  }

  Future<void> _openSearchScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchTeachersScreen()),
    );
    _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openBulkImport() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BulkImportTeachersScreen()),
    );
    ref.invalidate(teachersListControllerProvider);
    _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openCreateTeacher() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    ref.invalidate(teachersListControllerProvider);
    _searchSectionKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshList,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TeacherActionCardsRow(
              onUpdate: _openUpdateTeacher,
              onDelete: _openDeleteTeacher,
              onSearch: _openSearchScreen,
              onBulkImport: _openBulkImport,
              onCreate: _openCreateTeacher,
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
            TeacherSearchSection(key: _searchSectionKey),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}