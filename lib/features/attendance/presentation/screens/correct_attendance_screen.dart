import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/attendance/data/models/student_daily_attendance_roster.dart';
import 'package:cms/features/attendance/data/models/daily_attendance_correction_request.dart';
import 'package:cms/features/attendance/application/daily_attendance_roster_provider.dart';
import 'package:cms/features/attendance/application/submit_daily_attendance_controller.dart';

const List<Map<String, String>> _morningCheckpointOptions = [
  {'value': 'present', 'label': 'Present'},
  {'value': 'absent', 'label': 'Absent'},
  {'value': 'late', 'label': 'Late'},
  {'value': 'leave', 'label': 'Leave'},
];

const List<Map<String, String>> _closingCheckpointOptions = [
  {'value': 'present', 'label': 'Present'},
  {'value': 'absent', 'label': 'Absent'},
  {'value': 'leave', 'label': 'Leave'},
];

class CorrectAttendanceScreen extends ConsumerStatefulWidget {
  const CorrectAttendanceScreen({super.key});

  @override
  ConsumerState<CorrectAttendanceScreen> createState() =>
      _CorrectAttendanceScreenState();
}

class _CorrectAttendanceScreenState
    extends ConsumerState<CorrectAttendanceScreen> {
  SchoolClass? _selectedClass;
  DateTime _date = DateTime.now();
  final _batchReasonController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _batchReasonController.dispose();
    super.dispose();
  }

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
      setState(() => _date = picked);
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _statusBg(status),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _statusColor(status).withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _openCorrectionDialog(DailyRosterStudent student) async {
    String? selectedMorning = student.morningStatus;
    String? selectedClosing = student.closingStatus;
    final remarksController = TextEditingController(text: student.remarks ?? '');
    final reasonController = TextEditingController(
      text: _batchReasonController.text.trim(),
    );
    final formKey = GlobalKey<FormState>();

    final applied = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: Color(0xFF1769D1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Correct Attendance: ${student.studentName}',
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Roll #${student.rollNumber.isNotEmpty ? student.rollNumber : '-'} • Date: ${_fmt(_date)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Morning Arrival Checkpoint',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String?>(
                        isExpanded: true,
                        initialValue: selectedMorning,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Not Set / Unmarked', overflow: TextOverflow.ellipsis),
                          ),
                          ..._morningCheckpointOptions.map(
                            (o) => DropdownMenuItem(
                              value: o['value'],
                              child: Text(o['label']!, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (v) => setDialogState(() => selectedMorning = v),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Closing Off-Time Checkpoint',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String?>(
                        isExpanded: true,
                        initialValue: selectedClosing,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Not Set / Unmarked', overflow: TextOverflow.ellipsis),
                          ),
                          ..._closingCheckpointOptions.map(
                            (o) => DropdownMenuItem(
                              value: o['value'],
                              child: Text(o['label']!, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (v) => setDialogState(() => selectedClosing = v),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: remarksController,
                        decoration: const InputDecoration(
                          labelText: 'Remarks (Optional)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: reasonController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Reason for Audit Correction *',
                          hintText: 'e.g. Medical certificate verified by principal',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Audit reason is strictly required by school policy';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;

                    final hasChanged = selectedMorning != student.morningStatus ||
                        selectedClosing != student.closingStatus ||
                        remarksController.text.trim() != (student.remarks ?? '');

                    if (!hasChanged) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No changes were made to attendance.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final request = DailyAttendanceCorrectionRequest(
                      attendanceDate: _fmt(_date),
                      morningStatus: selectedMorning,
                      closingStatus: selectedClosing,
                      remarks: remarksController.text.trim().isEmpty
                          ? null
                          : remarksController.text.trim(),
                      reason: reasonController.text.trim(),
                    );

                    final notifier = ref.read(
                      submitDailyAttendanceControllerProvider.notifier,
                    );
                    final success = await notifier.correctAttendance(
                      classId: _selectedClass!.id,
                      studentId: student.studentId,
                      request: request,
                    );

                    if (ctx.mounted) {
                      Navigator.of(ctx).pop(success);
                    }
                  },
                  child: const Text('Save Correction'),
                ),
              ],
            );
          },
        );
      },
    );

    if (applied == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Daily attendance corrected and audit log recorded.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      ref.invalidate(
        dailyAttendanceRosterProvider(
          DailyRosterQuery(classId: _selectedClass!.id, date: _date),
        ),
      );
    } else if (applied == false && mounted) {
      final state = ref.read(submitDailyAttendanceControllerProvider);
      final errorMsg = state.hasError
          ? friendlyErrorMessage(state.error!)
          : 'Failed to correct attendance';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(allClassesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Correct Daily Attendance')),
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
                onChanged: (cls) => setState(() => _selectedClass = cls),
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
                        width: isNarrow ? constraints.maxWidth : 160,
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
                        width: isNarrow ? constraints.maxWidth : 260,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search student name / roll #',
                            prefixIcon: Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                        ),
                      ),
                      SizedBox(
                        width: isNarrow ? constraints.maxWidth : 250,
                        child: TextField(
                          controller: _batchReasonController,
                          decoration: const InputDecoration(
                            labelText: 'Default Audit Reason (Optional)',
                            hintText: 'Prefills correction dialog',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              Expanded(child: _buildRosterList()),
            ] else
              const Expanded(
                child: Center(
                  child: Text(
                    'Select a class and date to audit or correct student daily attendance records',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRosterList() {
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
            Text('Failed to load roster: ${friendlyErrorMessage(e)}'),
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
        var students = roster.students;
        if (_searchQuery.isNotEmpty) {
          students = students.where((s) {
            return s.studentName.toLowerCase().contains(_searchQuery) ||
                s.rollNumber.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (students.isEmpty) {
          return const Center(
            child: Text('No students found for this class & query.'),
          );
        }

        return Card(
          margin: EdgeInsets.zero,
          child: ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, unused) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1769D1).withValues(alpha: 0.1),
                  child: Text(
                    student.rollNumber.isNotEmpty
                        ? student.rollNumber
                        : '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1769D1),
                    ),
                  ),
                ),
                title: Text(
                  student.studentName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Morning: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        _buildStatusChip(student.morningStatus),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Closing: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        _buildStatusChip(student.closingStatus),
                      ],
                    ),
                    if (student.remarks != null && student.remarks!.isNotEmpty)
                      Text(
                        '(${student.remarks})',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                  ],
                ),
                trailing: OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Correct'),
                  onPressed: () => _openCorrectionDialog(student),
                ),
                onTap: () => _openCorrectionDialog(student),
              );
            },
          ),
        );
      },
    );
  }
}