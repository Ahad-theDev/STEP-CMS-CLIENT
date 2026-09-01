import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/delete_lecture_controller.dart';
import '../../data/models/lecture.dart';
import '../widgets/lecture_action_cards_row.dart';
import '../widgets/lecture_search_section.dart';
import 'add_lecture_screen.dart';
import 'select_lecture_screen.dart';
import 'update_lecture_screen.dart';
import 'create_override_screen.dart';

class LectureManagementScreen extends ConsumerStatefulWidget {
  const LectureManagementScreen({super.key});

  @override
  ConsumerState<LectureManagementScreen> createState() => _LectureManagementScreenState();
}

class _LectureManagementScreenState extends ConsumerState<LectureManagementScreen> {
  final _searchSectionKey = GlobalKey<LectureSearchSectionState>();

  Future<void> _openAddLecture() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddLectureScreen()),
    );
    if (created == true) _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openUpdateLecture() async {
    final selected = await Navigator.of(context).push<Lecture>(
      MaterialPageRoute(builder: (_) => const SelectLectureScreen(title: 'Select Lecture to Update')),
    );
    if (selected == null || !mounted) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UpdateLectureScreen(lecture: selected)),
    );
    if (updated == true) _searchSectionKey.currentState?.refresh();
  }

  Future<void> _openCreateOverride() async {
    final selected = await Navigator.of(context).push<Lecture>(
      MaterialPageRoute(
          builder: (_) => const SelectLectureScreen(title: 'Select Lecture for Override')),
    );
    if (selected == null || !mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreateOverrideScreen(lecture: selected)),
    );
  }

  Future<void> _openDeleteLecture() async {
    final selected = await Navigator.of(context).push<Lecture>(
      MaterialPageRoute(builder: (_) => const SelectLectureScreen(title: 'Select Lecture to Delete')),
    );
    if (selected == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lecture'),
        content: Text(
          '${selected.dayOfWeek[0].toUpperCase()}${selected.dayOfWeek.substring(1)} • Room ${selected.roomNumber} — '
          'deactivate this permanent slot?',
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
        await ref.read(deleteLectureControllerProvider.notifier).deleteLecture(selected.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lecture deactivated')));
      _searchSectionKey.currentState?.refresh();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to delete lecture')));
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
      appBar: AppBar(title: const Text('Lectures')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LectureActionCardsRow(
              onCreate: _openAddLecture,
              onUpdate: _openUpdateLecture,
              onCreateOverride: _openCreateOverride,
              onDelete: _openDeleteLecture,
              onSearch: _scrollToSearch,
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
            LectureSearchSection(key: _searchSectionKey),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}