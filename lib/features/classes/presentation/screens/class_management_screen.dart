import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/delete_class_controller.dart';
import '../../data/models/school_class.dart';
import '../widgets/class_action_cards_row.dart';
import '../widgets/class_search_section.dart';
import 'add_class_screen.dart';
import 'select_class_screen.dart';
import 'update_class_screen.dart';
import 'assign_teacher_screen.dart';
import 'bulk_import_classes_screen.dart';
import 'search_classes_screen.dart';

class ClassManagementScreen extends ConsumerStatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  ConsumerState<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends ConsumerState<ClassManagementScreen> {
  final _searchSectionKey = GlobalKey<ClassSearchSectionState>();

  Future<void> _openAddClass() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddClassScreen()),
    );
    if (created == true) _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openUpdateClass() async {
    final selected = await Navigator.of(context).push<SchoolClass>(
      MaterialPageRoute(builder: (_) => const SelectClassScreen(title: 'Select Class to Update')),
    );
    if (selected == null || !mounted) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UpdateClassScreen(schoolClass: selected)),
    );
    if (updated == true) _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openAssignTeacher() async {
    final selected = await Navigator.of(context).push<SchoolClass>(
      MaterialPageRoute(
          builder: (_) => const SelectClassScreen(title: 'Select Class to Assign Teacher')),
    );
    if (selected == null || !mounted) return;
    final assigned = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AssignTeacherScreen(schoolClass: selected)),
    );
    if (assigned == true) _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openDeleteClass() async {
    final selected = await Navigator.of(context).push<SchoolClass>(
      MaterialPageRoute(builder: (_) => const SelectClassScreen(title: 'Select Class to Delete')),
    );
    if (selected == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text(
          'Deactivate ${selected.name} - ${selected.section}? '
          'This will fail if any active students are still enrolled in it.',
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

    final success = await ref.read(deleteClassControllerProvider.notifier).deleteClass(selected.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class deactivated')));
      _searchSectionKey.currentState?.refresh();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to delete class')));
    }
  }

  Future<void> _openBulkImport() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BulkImportClassesScreen()),
    );
    _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openSearchScreen() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SearchClassesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _searchSectionKey.currentState?.refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClassActionCardsRow(
              onCreate: _openAddClass,
              onUpdate: _openUpdateClass,
              onAssignTeacher: _openAssignTeacher,
              onDelete: _openDeleteClass,
              onSearch: _openSearchScreen,
              onBulkImport: _openBulkImport,
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
            ClassSearchSection(key: _searchSectionKey),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}