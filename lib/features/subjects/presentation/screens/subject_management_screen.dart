import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/delete_subject_controller.dart';
import '../../application/subjects_list_controller.dart';
import '../../data/models/subject.dart';
import '../widgets/subject_action_cards_row.dart';
import '../widgets/subject_search_section.dart';
import 'add_subject_screen.dart';
import 'select_subject_screen.dart';
import 'update_subject_screen.dart';
import 'search_subject_screen.dart';

class SubjectManagementScreen extends ConsumerStatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  ConsumerState<SubjectManagementScreen> createState() => _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends ConsumerState<SubjectManagementScreen> {
  final _searchSectionKey = GlobalKey<SubjectSearchSectionState>();

  Future<void> _refreshSubjects() async {
    await ref.read(subjectsListControllerProvider.notifier).refresh();
  }

  Future<void> _openAddSubject() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddSubjectScreen()),
    );
    if (created == true) _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openUpdateSubject() async {
    final selected = await Navigator.of(context).push<Subject>(
      MaterialPageRoute(builder: (_) => const SelectSubjectScreen(title: 'Select Subject to Update')),
    );
    if (selected == null || !mounted) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UpdateSubjectScreen(subject: selected)),
    );
    if (updated == true) _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openDeleteSubject() async {
    final selected = await Navigator.of(context).push<Subject>(
      MaterialPageRoute(builder: (_) => const SelectSubjectScreen(title: 'Select Subject to Delete')),
    );
    if (selected == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Deactivate ${selected.name}? '
          'This will fail if any active lectures still reference it.',
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

    final success =
        await ref.read(deleteSubjectControllerProvider.notifier).deleteSubject(selected.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subject deactivated')));
      _searchSectionKey.currentState?.refresh();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to delete subject')));
    }
  }

  Future<void> _openSearchScreen() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SearchSubjectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSubjects,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubjectActionCardsRow(
              onCreate: _openAddSubject,
              onUpdate: _openUpdateSubject,
              onDelete: _openDeleteSubject,
              onSearch: _openSearchScreen,
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
            SubjectSearchSection(key: _searchSectionKey),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}