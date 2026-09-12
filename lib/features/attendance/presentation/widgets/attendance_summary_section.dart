import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/attendance_summary_controller.dart';

class AttendanceSummarySection extends ConsumerStatefulWidget {
  const AttendanceSummarySection({super.key});

  @override
  ConsumerState<AttendanceSummarySection> createState() => _AttendanceSummarySectionState();
}

class _AttendanceSummarySectionState extends ConsumerState<AttendanceSummarySection> {
  SchoolClass? _selectedClass;
  DateTime _dateFrom = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dateTo = DateTime.now();

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _dateFrom, end: _dateTo),
    );
    if (picked != null) {
      setState(() {
        _dateFrom = picked.start;
        _dateTo = picked.end;
      });
    }
  }

  Color _pctColor(double pct) {
    if (pct >= 85) return Colors.green;
    if (pct >= 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          classesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Failed to load classes: ${friendlyErrorMessage(e)}',
                style: const TextStyle(color: Colors.red)),
            data: (classes) => DropdownButtonFormField<SchoolClass>(
              initialValue: _selectedClass,
              decoration: const InputDecoration(labelText: 'Select Class'),
              items: classes
                  .map((c) => DropdownMenuItem(value: c, child: Text('${c.name} - ${c.section}')))
                  .toList(),
              onChanged: (v) => setState(() => _selectedClass = v),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickRange,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date Range'),
              child: Text('${_fmt(_dateFrom)} to ${_fmt(_dateTo)}'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedClass != null
                ? _buildTable()
                : const Center(child: Text('Select a class to see its summary')),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final summaryAsync = ref.watch(attendanceSummaryControllerProvider(
      classId: _selectedClass!.id,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    ));

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load summary: ${friendlyErrorMessage(e)}')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No attendance data in this range'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Student')),
              DataColumn(label: Text('Present')),
              DataColumn(label: Text('Absent')),
              DataColumn(label: Text('Late')),
              DataColumn(label: Text('Leave')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('%')),
            ],
            rows: items
                .map((s) => DataRow(cells: [
                      DataCell(Text(s.studentName)),
                      DataCell(Text('${s.presentCount}')),
                      DataCell(Text('${s.absentCount}')),
                      DataCell(Text('${s.lateCount}')),
                      DataCell(Text('${s.leaveCount}')),
                      DataCell(Text('${s.totalLectures}')),
                      DataCell(Text(
                        '${s.percentagePresent.toStringAsFixed(1)}%',
                        style: TextStyle(color: _pctColor(s.percentagePresent), fontWeight: FontWeight.bold),
                      )),
                    ]))
                .toList(),
          ),
        );
      },
    );
  }
}