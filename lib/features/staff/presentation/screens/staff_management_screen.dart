import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/delete_staff_controller.dart';
import '../../data/models/staff_member.dart';
import '../widgets/staff_action_cards_row.dart';
import '../widgets/staff_search_section.dart';
import 'add_staff_screen.dart';
import 'select_staff_screen.dart';
import 'update_staff_screen.dart';
import 'view_staff_screen.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  final _searchSectionKey = GlobalKey<StaffSearchSectionState>();

  Future<void> _openAddStaff() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddStaffScreen()),
    );
    if (created == true) {
      _searchSectionKey.currentState?.refresh();
    }
  }

  Future<void> _openUpdateStaff() async {
    final selected = await Navigator.of(context).push<StaffMember>(
      MaterialPageRoute(builder: (_) => const SelectStaffScreen(title: 'Select Staff to Update')),
    );
    if (selected == null || !mounted) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UpdateStaffScreen(staff: selected)),
    );
    if (updated == true) {
      _searchSectionKey.currentState?.refresh();
    }
  }

  Future<void> _openDeleteStaff() async {
    final selected = await Navigator.of(context).push<StaffMember>(
      MaterialPageRoute(builder: (_) => const SelectStaffScreen(title: 'Select Staff to Delete')),
    );
    if (selected == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Staff'),
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

    final success = await ref.read(deleteStaffControllerProvider.notifier).deleteStaff(selected.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff deactivated')));
      _searchSectionKey.currentState?.refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete staff')));
    }
  }

  Future<void> _openSearchStaff() async {
    final selectedStaff = await Navigator.of(context).push<StaffMember>(
      MaterialPageRoute(
        builder: (_) => const SelectStaffScreen(title: 'Search Staff'),
      ),
    );

    if (selectedStaff != null && mounted) {
      // Navigate to staff detail screen
      await Navigator.of(context).push<dynamic>(
        MaterialPageRoute(
          builder: (_) => ViewStaffScreen(staff: selectedStaff),
        ),
      );
      // Refresh the staff list after returning from detail screen
      _searchSectionKey.currentState?.refresh();
    } else if (mounted) {
      // If no staff was selected (user went back), just refresh
      _searchSectionKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff'),
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
            StaffActionCardsRow(
              onCreate: _openAddStaff,
              onUpdate: _openUpdateStaff,
              onDelete: _openDeleteStaff,
              onSearch: _openSearchStaff,
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
            StaffSearchSection(key: _searchSectionKey),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}