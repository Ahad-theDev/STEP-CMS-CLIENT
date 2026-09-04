import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/calendar_list_controller.dart';
import '../../application/delete_calendar_entries_controller.dart';
import 'add_calendar_entry_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = DateTime(now.year, now.month + 1, 0);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
    }
  }

  Future<void> _openAddEntry() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddCalendarEntryScreen()),
    );
    if (created == true) {
      ref.invalidate(calendarListControllerProvider(fromDate: _from, toDate: _to));
    }
  }

  Future<void> _deleteSingleDate(String dateStr) async {
    final date = DateTime.parse(dateStr);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Remove the calendar entry on $dateStr?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result =
        await ref.read(deleteCalendarEntriesControllerProvider.notifier).deleteEntries(date, null);
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${result.deletedCount} entr${result.deletedCount == 1 ? 'y' : 'ies'}')));
      ref.invalidate(calendarListControllerProvider(fromDate: _from, toDate: _to));
    } else {
      final error = ref.read(deleteCalendarEntriesControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete: ${error != null ? friendlyErrorMessage(error) : 'Unknown error'}'),
      ));
    }
  }

  Future<void> _clearWholeRange() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Range'),
        content: Text('Remove ALL calendar entries between ${_fmt(_from)} and ${_fmt(_to)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result =
        await ref.read(deleteCalendarEntriesControllerProvider.notifier).deleteEntries(_from, _to);
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${result.deletedCount} entr${result.deletedCount == 1 ? 'y' : 'ies'}')));
      ref.invalidate(calendarListControllerProvider(fromDate: _from, toDate: _to));
    } else {
      final error = ref.read(deleteCalendarEntriesControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to clear range: ${error != null ? friendlyErrorMessage(error) : 'Unknown error'}'),
      ));
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'holiday':
        return Icons.beach_access_rounded;
      case 'half_day':
        return Icons.wb_twilight_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(calendarListControllerProvider(fromDate: _from, toDate: _to));

    return Scaffold(
      appBar: AppBar(title: const Text('Academic Calendar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickRange,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Range'),
                      child: Text('${_fmt(_from)} to ${_fmt(_to)}'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearWholeRange,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: const Text('Clear Range'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _openAddEntry,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load calendar: ${friendlyErrorMessage(e)}')),
              data: (entries) {
                if (entries.isEmpty) {
                  return const Center(child: Text('No calendar entries in this range'));
                }
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      leading: Icon(_iconFor(entry.type)),
                      title: Text(entry.date),
                      subtitle: Text(
                          entry.type[0].toUpperCase() + entry.type.substring(1).replaceAll('_', ' ')),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteSingleDate(entry.date),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}