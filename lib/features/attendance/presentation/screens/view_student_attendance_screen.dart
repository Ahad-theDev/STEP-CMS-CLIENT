import 'package:cms/features/attendance/application/all_students_for_class_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/lectures/application/all_lectures_for_class_controller.dart';
import 'package:cms/features/lectures/data/models/lecture.dart';
import 'package:cms/features/students/data/models/student.dart';
import '../../application/student_attendance_list_controller.dart';

const List<Map<String, String>> _statusFilterOptions = [
  {'value': 'present', 'label': 'Present'},
  {'value': 'absent', 'label': 'Absent'},
  {'value': 'late', 'label': 'Late'},
  {'value': 'leave', 'label': 'Leave'},
];

class ViewStudentAttendanceScreen extends ConsumerStatefulWidget {
  const ViewStudentAttendanceScreen({super.key});

  @override
  ConsumerState<ViewStudentAttendanceScreen> createState() => _ViewStudentAttendanceScreenState();
}

class _ViewStudentAttendanceScreenState extends ConsumerState<ViewStudentAttendanceScreen> {
  SchoolClass? _selectedClass;
  Lecture? _selectedLecture;
  Student? _selectedStudent;
  String? _selectedStatus;
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

  void _onClassChanged(SchoolClass? cls) {
    setState(() {
      _selectedClass = cls;
      _selectedLecture = null;
      _selectedStudent = null;
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                onChanged: _onClassChanged,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedClass != null) ...[
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  SizedBox(width: 220, child: _buildLectureDropdown()),
                  SizedBox(width: 200, child: _buildStudentDropdown()),
                  SizedBox(
                    width: 160,
                    child: DropdownButtonFormField<String?>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('All')),
                        ..._statusFilterOptions.map(
                            (o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!))),
                      ],
                      onChanged: (v) => setState(() => _selectedStatus = v),
                    ),
                  ),
                ],
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
              Expanded(child: _buildResults()),
            ] else
              const Expanded(child: Center(child: Text('Select a class to view attendance'))),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureDropdown() {
    final lecturesAsync =
        ref.watch(allLecturesForClassControllerProvider(classId: _selectedClass!.id));
    return lecturesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Failed: ${friendlyErrorMessage(e)}',
          style: const TextStyle(color: Colors.red, fontSize: 12)),
      data: (lectures) => DropdownButtonFormField<Lecture?>(
        initialValue: _selectedLecture,
        decoration: const InputDecoration(labelText: 'Lecture'),
        isExpanded: true,
        items: [
          const DropdownMenuItem<Lecture?>(value: null, child: Text('All Lectures')),
          ...lectures.map((l) => DropdownMenuItem(
                value: l,
                child: Text(
                  '${l.dayOfWeek[0].toUpperCase()}${l.dayOfWeek.substring(1)} ${TimeOfDayUtils.displayLabel(l.startTime)}',
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
        onChanged: (v) => setState(() => _selectedLecture = v),
      ),
    );
  }

  Widget _buildStudentDropdown() {
    final studentsAsync =
        ref.watch(allStudentsForClassControllerProvider(classId: _selectedClass!.id));
    return studentsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Failed: ${friendlyErrorMessage(e)}',
          style: const TextStyle(color: Colors.red, fontSize: 12)),
      data: (students) => DropdownButtonFormField<Student?>(
        initialValue: _selectedStudent,
        decoration: const InputDecoration(labelText: 'Student'),
        isExpanded: true,
        items: [
          const DropdownMenuItem<Student?>(value: null, child: Text('All Students')),
          ...students.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.fullName, overflow: TextOverflow.ellipsis),
              )),
        ],
        onChanged: (v) => setState(() => _selectedStudent = v),
      ),
    );
  }

  Widget _buildResults() {
    final studentsAsync =
        ref.watch(allStudentsForClassControllerProvider(classId: _selectedClass!.id));
    final phoneByStudentId = {
      for (final s in studentsAsync.valueOrNull ?? <Student>[]) s.id: s.guardianPhone,
    };

    final recordsAsync = ref.watch(studentAttendanceListControllerProvider(
      classId: _selectedClass!.id,
      date: _date,
      lectureId: _selectedLecture?.id,
      studentId: _selectedStudent?.id,
      status: _selectedStatus,
    ));

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
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Remarks')),
            ],
            rows: records
                .map((r) => DataRow(cells: [
                      DataCell(Text(r.studentName)),
                      DataCell(Text(phoneByStudentId[r.studentId] ?? '-')),
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