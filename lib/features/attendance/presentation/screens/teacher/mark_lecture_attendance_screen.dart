import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../../application/lecture_roster_controller.dart';
import '../../../application/mark_student_attendance_controller.dart';
import '../../../data/models/attendance_mark_request.dart';

const List<Map<String, String>> _statusOptions = [
  {'value': 'present', 'label': 'Present'},
  {'value': 'absent', 'label': 'Absent'},
  {'value': 'late', 'label': 'Late'},
  {'value': 'leave', 'label': 'Leave'},
];

class _RosterRow {
  final String studentId;
  final String name;
  final String rollNumber;
  String? localStatus;

  _RosterRow({required this.studentId, required this.name, required this.rollNumber});
}

class MarkLectureAttendanceScreen extends ConsumerStatefulWidget {
  final String lectureId;
  const MarkLectureAttendanceScreen({super.key, required this.lectureId});

  @override
  ConsumerState<MarkLectureAttendanceScreen> createState() => _MarkLectureAttendanceScreenState();
}

class _MarkLectureAttendanceScreenState extends ConsumerState<MarkLectureAttendanceScreen> {
  DateTime _date = DateTime.now();
  List<_RosterRow>? _rows;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _rows = null;
      });
    }
  }

  void _markAllPresent() {
    if (_rows == null) return;
    setState(() {
      for (final row in _rows!) {
        row.localStatus ??= 'present';
      }
    });
  }

  Future<void> _save() async {
    final toSubmit = _rows?.where((r) => r.localStatus != null).toList() ?? [];
    if (toSubmit.isEmpty) return;

    final request = AttendanceMarkRequest(
      lectureId: widget.lectureId,
      date: _date,
      attendance: toSubmit
          .map((r) => AttendanceMarkEntryRequest(studentId: r.studentId, status: r.localStatus!))
          .toList(),
    );

    final result = await ref.read(markStudentAttendanceControllerProvider.notifier).submit(request);
    if (!mounted) return;

    if (result == null) {
      final error = ref.read(markStudentAttendanceControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save: ${error != null ? friendlyErrorMessage(error) : 'Unknown error'}'),
      ));
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Marked ${result.marked} student(s)')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final rosterAsync =
        ref.watch(lectureRosterControllerProvider(lectureId: widget.lectureId, date: _date));
    final submitState = ref.watch(markStudentAttendanceControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as Present',
            onPressed: _rows == null ? null : _markAllPresent,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(_fmt(_date)),
              ),
            ),
          ),
          Expanded(
            child: rosterAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Failed to load roster: ${friendlyErrorMessage(e)}')),
              data: (roster) {
                _rows ??= roster.students
                    .map((s) => _RosterRow(studentId: s.id, name: s.name, rollNumber: s.rollNumber))
                    .toList();

                if (_rows!.isEmpty) {
                  return const Center(child: Text('No students in this class'));
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(roster.subject,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _rows!.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final row = _rows![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(row.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text('Roll #${row.rollNumber}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: _statusOptions.map((opt) {
                                      final selected = row.localStatus == opt['value'];
                                      return ChoiceChip(
                                        label:
                                            Text(opt['label']!, style: const TextStyle(fontSize: 12)),
                                        selected: selected,
                                        onSelected: (_) => setState(
                                            () => row.localStatus = selected ? null : opt['value']),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: submitState.isLoading ? null : _save,
            child: submitState.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    'Save'
                    '${_rows != null && _rows!.any((r) => r.localStatus != null) ? ' (${_rows!.where((r) => r.localStatus != null).length})' : ''}',
                  ),
          ),
        ),
      ),
    );
  }
}