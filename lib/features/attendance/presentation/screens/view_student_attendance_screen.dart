import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/student_attendance_list_controller.dart';

class ViewStudentAttendanceScreen extends ConsumerStatefulWidget {
  const ViewStudentAttendanceScreen({super.key});

  @override
  ConsumerState<ViewStudentAttendanceScreen> createState() => _ViewStudentAttendanceScreenState();
}

class _ViewStudentAttendanceScreenState extends ConsumerState<ViewStudentAttendanceScreen> {
  SchoolClass? _selectedClass;
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
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));

    return Scaffold(
      appBar: AppBar(title: const Text('View Attendance')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              classesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) =>
                    Text('Failed to load classes: ${friendlyErrorMessage(e)}',
                        style: const TextStyle(color: Colors.red)),
                data: (classes) => DropdownButtonFormField<SchoolClass>(
                  initialValue: _selectedClass,
                  decoration: const InputDecoration(labelText: 'Select Class'),
                  items: classes
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('${c.name} - ${c.section}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedClass = v),
                ),
              ),
              const SizedBox(height: 12),
              Row(
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
              const SizedBox(height: 16),
              if (_selectedClass != null)
                SizedBox(
                  height: 400,
                  child: _buildResults())
              else
                const SizedBox(
                  height: 400,
                  child: Center(child: Text('Select a class to view attendance'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final recordsAsync = ref
        .watch(studentAttendanceListControllerProvider(classId: _selectedClass!.id, date: _date));

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load: ${friendlyErrorMessage(e)}')),
      data: (records) {
        if (records.isEmpty) {
          return const Center(child: Text('No attendance records found'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Student')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Remarks')),
            ],
            rows: records
                .map((r) => DataRow(cells: [
                      DataCell(Text(r.studentName)),
                      DataCell(Text(r.date)),
                      DataCell(Chip(
                        label: Text(r.status[0].toUpperCase() + r.status.substring(1),
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: _statusColor(r.status),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      DataCell(Text(r.remarks ?? '-')),
                    ]))
                .toList(),
          ),
        );
      },
    );
  }
}