import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/staff/application/all_staff_list_controller.dart';
import 'package:cms/features/staff/data/models/staff_member.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import '../../application/mark_staff_attendance_controller.dart';
import '../../data/models/staff_attendance_mark_request.dart';

class MarkStaffAttendanceScreen extends ConsumerStatefulWidget {
  const MarkStaffAttendanceScreen({super.key});

  @override
  ConsumerState<MarkStaffAttendanceScreen> createState() => _MarkStaffAttendanceScreenState();
}

class _MarkStaffAttendanceScreenState extends ConsumerState<MarkStaffAttendanceScreen> {
  bool _isStaff = true;
  StaffMember? _selectedStaff;
  Teacher? _selectedTeacher;
  DateTime _date = DateTime.now();
  String _status = 'present';

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

  Future<void> _submit() async {
    if (_isStaff && _selectedStaff == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a staff member')));
      return;
    }
    if (!_isStaff && _selectedTeacher == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a teacher')));
      return;
    }

    final request = StaffAttendanceMarkRequest(
      staffId: _isStaff ? _selectedStaff!.id : null,
      teacherId: _isStaff ? null : _selectedTeacher!.id,
      date: _date,
      status: _status,
    );

    final result =
        await ref.read(markStaffAttendanceControllerProvider.notifier).markAttendance(request);
    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Marked ${result.status} for ${result.personName}')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(markStaffAttendanceControllerProvider);
    final staffAsync = ref.watch(allStaffListControllerProvider);
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Staff'),
                  selected: _isStaff,
                  onSelected: (v) => setState(() => _isStaff = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Teacher'),
                  selected: !_isStaff,
                  onSelected: (v) => setState(() => _isStaff = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isStaff)
              staffAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Failed to load staff: ${friendlyErrorMessage(e)}',
                    style: const TextStyle(color: Colors.red)),
                data: (staffList) => DropdownButtonFormField<StaffMember>(
                  initialValue: _selectedStaff,
                  decoration: const InputDecoration(labelText: 'Staff Member'),
                  items: staffList
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.fullName)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStaff = v),
                ),
              )
            else
              teachersAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Failed to load teachers: ${friendlyErrorMessage(e)}',
                    style: const TextStyle(color: Colors.red)),
                data: (teachers) => DropdownButtonFormField<Teacher>(
                  initialValue: _selectedTeacher,
                  decoration: const InputDecoration(labelText: 'Teacher'),
                  items: teachers
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.fullName)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTeacher = v),
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
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'present', child: Text('Present')),
                DropdownMenuItem(value: 'absent', child: Text('Absent')),
                DropdownMenuItem(value: 'late', child: Text('Late')),
                DropdownMenuItem(value: 'leave', child: Text('Leave')),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 24),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Failed: ${friendlyErrorMessage(state.error!)}',
                    style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Mark Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}