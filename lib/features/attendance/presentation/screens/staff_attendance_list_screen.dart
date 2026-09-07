import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/staff_attendance_list_controller.dart';

class StaffAttendanceListScreen extends ConsumerStatefulWidget {
  const StaffAttendanceListScreen({super.key});

  @override
  ConsumerState<StaffAttendanceListScreen> createState() => _StaffAttendanceListScreenState();
}

class _StaffAttendanceListScreenState extends ConsumerState<StaffAttendanceListScreen> {
  DateTime? _date = DateTime.now();

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'leave':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(staffAttendanceListControllerProvider(date: _date));

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Attendance')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date'),
                      child: Text(_date == null ? 'All dates' : _fmt(_date!)),
                    ),
                  ),
                ),
                if (_date != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Show all dates',
                    onPressed: () => setState(() => _date = null),
                  ),
              ],
            ),
          ),
          Expanded(
            child: attendanceAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load: ${friendlyErrorMessage(e)}')),
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('No attendance records found'));
                }
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final r = records[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                            r.personType == 'staff' ? Icons.badge_outlined : Icons.school_outlined),
                      ),
                      title: Text(r.personName),
                      subtitle: Text(
                          '${r.personType[0].toUpperCase()}${r.personType.substring(1)} • ${r.date}'),
                      trailing: Chip(
                        label: Text(
                          r.status[0].toUpperCase() + r.status.substring(1),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: _statusColor(r.status),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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