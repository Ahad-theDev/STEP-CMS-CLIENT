import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/students/data/models/student.dart';
import 'package:cms/features/attendance/application/all_students_for_class_controller.dart';
import 'package:cms/features/attendance/application/daily_attendance_roster_provider.dart';

const List<Map<String, String>> _statusFilterOptions = [
  {'value': 'present', 'label': 'Present'},
  {'value': 'absent', 'label': 'Absent'},
  {'value': 'late', 'label': 'Late'},
  {'value': 'half_day', 'label': 'Half Day / Short Leave'},
  {'value': 'leave', 'label': 'Leave'},
];

class ViewStudentAttendanceScreen extends ConsumerStatefulWidget {
  const ViewStudentAttendanceScreen({super.key});

  @override
  ConsumerState<ViewStudentAttendanceScreen> createState() =>
      _ViewStudentAttendanceScreenState();
}

class _ViewStudentAttendanceScreenState
    extends ConsumerState<ViewStudentAttendanceScreen> {
  SchoolClass? _selectedClass;
  Student? _selectedStudent;
  String? _selectedStatus;
  DateTime _date = DateTime.now();

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _onClassChanged(SchoolClass? cls) {
    setState(() {
      _selectedClass = cls;
      _selectedStudent = null;
    });
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return const Color(0xFF16A34A);
      case 'absent':
        return const Color(0xFFDC2626);
      case 'late':
        return const Color(0xFFD97706);
      case 'leave':
        return const Color(0xFF7C3AED);
      case 'half_day':
      case 'short_leave':
        return const Color(0xFFEA580C);
      default:
        return Colors.grey;
    }
  }

  Color _statusBg(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return const Color(0xFFDCFCE7);
      case 'absent':
        return const Color(0xFFFEE2E2);
      case 'late':
        return const Color(0xFFFEF3C7);
      case 'leave':
        return const Color(0xFFEDE9FE);
      case 'half_day':
      case 'short_leave':
        return const Color(0xFFFFEDD5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Widget _buildStatusChip(String? status) {
    final label = (status == null || status.isEmpty)
        ? 'Unmarked'
        : status.replaceAll('_', ' ').toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusBg(status),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _statusColor(status).withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(allClassesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('View Daily Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            classesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                'Failed to load classes: ${friendlyErrorMessage(e)}',
                style: const TextStyle(color: Colors.red),
              ),
              data: (classes) => DropdownButtonFormField<SchoolClass>(
                initialValue: _selectedClass,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: classes
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          '${c.name} - ${c.section}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _onClassChanged,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedClass != null) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 640;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: isNarrow ? (constraints.maxWidth - 12) / 2 : 160,
                        child: InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              suffixIcon: Icon(Icons.calendar_today, size: 18),
                            ),
                            child: Text(_fmt(_date)),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isNarrow ? (constraints.maxWidth - 12) / 2 : 180,
                        child: DropdownButtonFormField<String?>(
                          isExpanded: true,
                          initialValue: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status Filter',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'All Statuses',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ..._statusFilterOptions.map(
                              (o) => DropdownMenuItem(
                                value: o['value'],
                                child: Text(
                                  o['label']!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _selectedStatus = v),
                        ),
                      ),
                      SizedBox(
                        width: isNarrow ? constraints.maxWidth : 220,
                        child: _buildStudentDropdown(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildDailyResults()),
            ] else
              const Expanded(
                child: Center(
                  child: Text(
                    'Select a class to view daily student attendance records',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDropdown() {
    final studentsAsync = ref.watch(
      allStudentsForClassControllerProvider(classId: _selectedClass!.id),
    );
    return studentsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(
        'Failed: ${friendlyErrorMessage(e)}',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
      data: (students) => DropdownButtonFormField<Student?>(
        initialValue: _selectedStudent,
        decoration: const InputDecoration(
          labelText: 'Student Filter',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        isExpanded: true,
        items: [
          const DropdownMenuItem<Student?>(
            value: null,
            child: Text('All Students', overflow: TextOverflow.ellipsis),
          ),
          ...students.map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(
                s.rollNumber.isNotEmpty ? '${s.rollNumber} - ${s.fullName}' : s.fullName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (v) => setState(() => _selectedStudent = v),
      ),
    );
  }

  Widget _buildDailyResults() {
    final rosterAsync = ref.watch(
      dailyAttendanceRosterProvider(
        DailyRosterQuery(classId: _selectedClass!.id, date: _date),
      ),
    );

    return rosterAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load daily attendance: ${friendlyErrorMessage(e)}'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.invalidate(
                dailyAttendanceRosterProvider(
                  DailyRosterQuery(classId: _selectedClass!.id, date: _date),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (roster) {
        var filtered = roster.students;

        if (_selectedStudent != null) {
          filtered = filtered.where((s) => s.studentId == _selectedStudent!.id).toList();
        }

        if (_selectedStatus != null) {
          filtered = filtered.where((s) {
            final finalSt = s.finalStatus?.toLowerCase();
            final morningSt = s.morningStatus?.toLowerCase();
            if (_selectedStatus == 'half_day') {
              return finalSt == 'half_day' || morningSt == 'late';
            }
            return finalSt == _selectedStatus || morningSt == _selectedStatus;
          }).toList();
        }

        if (filtered.isEmpty) {
          return const Center(child: Text('No attendance records found for this filter.'));
        }

        // Summary counts
        final total = roster.students.length;
        final presentCount = roster.students
            .where((s) => s.finalStatus?.toLowerCase() == 'present' || (s.finalStatus == null && s.morningStatus?.toLowerCase() == 'present'))
            .length;
        final absentCount = roster.students
            .where((s) => s.finalStatus?.toLowerCase() == 'absent' || (s.finalStatus == null && s.morningStatus?.toLowerCase() == 'absent'))
            .length;
        final lateCount = roster.students
            .where((s) => s.finalStatus?.toLowerCase() == 'half_day' || s.morningStatus?.toLowerCase() == 'late')
            .length;
        final leaveCount = roster.students
            .where((s) => s.finalStatus?.toLowerCase() == 'leave' || s.morningStatus?.toLowerCase() == 'leave')
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _metricChip('Total: $total', Colors.grey.shade800, Colors.grey.shade100),
                  const SizedBox(width: 8),
                  _metricChip('Present: $presentCount', const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
                  const SizedBox(width: 8),
                  _metricChip('Absent: $absentCount', const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
                  const SizedBox(width: 8),
                  _metricChip('Late/Half-day: $lateCount', const Color(0xFFD97706), const Color(0xFFFEF3C7)),
                  const SizedBox(width: 8),
                  _metricChip('Leave: $leaveCount', const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Roll #')),
                      DataColumn(label: Text('Student Name')),
                      DataColumn(label: Text('Morning')),
                      DataColumn(label: Text('Closing')),
                      DataColumn(label: Text('Final Status')),
                      DataColumn(label: Text('Remarks')),
                    ],
                    rows: filtered.map((r) {
                      return DataRow(
                        cells: [
                          DataCell(Text(r.rollNumber.isNotEmpty ? r.rollNumber : '-')),
                          DataCell(Text(r.studentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(_buildStatusChip(r.morningStatus)),
                          DataCell(_buildStatusChip(r.closingStatus)),
                          DataCell(_buildStatusChip(r.finalStatus)),
                          DataCell(Text(r.remarks ?? '-')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _metricChip(String text, Color textCol, Color bgCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textCol,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
