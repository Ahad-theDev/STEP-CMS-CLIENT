import 'package:cms/features/attendance/application/all_students_for_class_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/lectures/presentation/screens/select_lecture_rich_screen.dart';
import 'package:cms/features/lectures/data/models/lecture.dart';
import '../../application/student_attendance_list_controller.dart';
import '../../application/bulk_correct_attendance_controller.dart';
import '../../data/models/bulk_correction_request.dart';

const List<Map<String, String>> _statusOptions = [
  {'value': 'present', 'label': 'Present'},
  {'value': 'absent', 'label': 'Absent'},
  {'value': 'late', 'label': 'Late'},
  {'value': 'leave', 'label': 'Leave'},
];

class _CorrectionRow {
  final String studentId;
  final String name;
  final String? originalStatus;
  String? localStatus;

  _CorrectionRow({required this.studentId, required this.name, this.originalStatus})
      : localStatus = originalStatus;

  bool get isDirty => localStatus != originalStatus;
  String get action => originalStatus == null ? 'add' : 'correct';
}

class CorrectAttendanceScreen extends ConsumerStatefulWidget {
  const CorrectAttendanceScreen({super.key});

  @override
  ConsumerState<CorrectAttendanceScreen> createState() => _CorrectAttendanceScreenState();
}

class _CorrectAttendanceScreenState extends ConsumerState<CorrectAttendanceScreen> {
  Lecture? _selectedLecture;
  DateTime _date = DateTime.now();
  final _reasonController = TextEditingController();
  List<_CorrectionRow>? _rows;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickLecture() async {
    final selected = await Navigator.of(context).push<Lecture>(
      MaterialPageRoute(builder: (_) => const SelectLectureRichScreen(title: 'Select Lecture')),
    );
    if (selected != null) {
      setState(() {
        _selectedLecture = selected;
        _rows = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() {
      _date = picked;
      _rows = null;
    });
  }

  Future<void> _save() async {
    final dirty = _rows?.where((r) => r.isDirty && r.localStatus != null).toList() ?? [];
    if (dirty.isEmpty) return;
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please provide a reason for these changes')));
      return;
    }

    final request = BulkCorrectionRequest(
      lectureId: _selectedLecture!.id,
      date: _date,
      corrections: dirty
          .map((r) => AttendanceCorrectionEntryRequest(
                studentId: r.studentId,
                status: r.localStatus!,
                reason: _reasonController.text.trim(),
                action: r.action,
              ))
          .toList(),
    );

    final result = await ref.read(bulkCorrectAttendanceControllerProvider.notifier).submit(request);
    if (!mounted) return;

    if (result == null) {
      final error = ref.read(bulkCorrectAttendanceControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Failed to save: ${error != null ? friendlyErrorMessage(error) : 'Unknown error'}'),
      ));
      return;
    }

    final skipped = result.results.where((r) => r.actionTaken.startsWith('skipped')).length;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Saved ${result.results.length - skipped} correction(s)'
        '${skipped > 0 ? ', $skipped skipped' : ''}',
      ),
    ));

    ref.invalidate(studentAttendanceListControllerProvider(
        classId: _selectedLecture!.classId, date: _date));
    setState(() => _rows = null);
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(bulkCorrectAttendanceControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Correct Attendance')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _pickLecture,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Lecture'),
                      child: Text(_selectedLecture == null
                          ? 'Tap to select'
                          : '${_selectedLecture!.dayOfWeek[0].toUpperCase()}${_selectedLecture!.dayOfWeek.substring(1)} • Room ${_selectedLecture!.roomNumber}'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date'),
                      child: Text(_fmt(_date)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason for correction',
                      helperText: 'Applied to every change you save in this batch',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 400,
              child: _selectedLecture == null
                  ? const Center(child: Text('Select a lecture to begin'))
                  : _buildRoster(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _selectedLecture == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: submitState.isLoading ? null : _save,
                  child: submitState.isLoading
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          'Save Corrections'
                          '${_rows != null && _rows!.any((r) => r.isDirty) ? ' (${_rows!.where((r) => r.isDirty).length})' : ''}',
                        ),
                ),
              ),
            ),
    );
  }

  Widget _buildRoster() {
    final studentsAsync =
        ref.watch(allStudentsForClassControllerProvider(classId: _selectedLecture!.classId));
    final recordsAsync = ref.watch(studentAttendanceListControllerProvider(
        classId: _selectedLecture!.classId, date: _date));

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load students: ${friendlyErrorMessage(e)}')),
      data: (students) => recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Failed to load attendance: ${friendlyErrorMessage(e)}')),
        data: (records) {
          if (_rows == null) {
            final statusByStudent = {for (final r in records) r.studentId: r.status};
            _rows = students
                .map((s) => _CorrectionRow(
                      studentId: s.id,
                      name: s.fullName,
                      originalStatus: statusByStudent[s.id],
                    ))
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));
          }

          if (_rows!.isEmpty) {
            return const Center(child: Text('No students in this class'));
          }

          return ListView.separated(
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
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(row.name, overflow: TextOverflow.ellipsis),
                          ),
                          if (row.isDirty)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.circle, size: 8, color: Colors.orange),
                            ),
                          if (row.originalStatus == null)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text('(unmarked)',
                                  style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
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
                            label: Text(opt['label']!, style: const TextStyle(fontSize: 12)),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => row.localStatus = selected ? null : opt['value']),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}