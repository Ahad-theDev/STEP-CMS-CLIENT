import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/staff/application/all_staff_list_controller.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import '../../application/staff_attendance_list_controller.dart';
import '../../application/staff_attendance_repository_provider.dart';
import '../../data/models/staff_attendance_mark_request.dart';
import '../models/attendance_roster_entry.dart';

const List<Map<String, String>> attendanceStatusOptions = [
  {'value': 'present', 'label': 'Present'},
  {'value': 'absent', 'label': 'Absent'},
  {'value': 'late', 'label': 'Late'},
  {'value': 'leave', 'label': 'Leave'},
];

class MarkStaffAttendanceScreen extends ConsumerStatefulWidget {
  const MarkStaffAttendanceScreen({super.key});

  @override
  ConsumerState<MarkStaffAttendanceScreen> createState() => _MarkStaffAttendanceScreenState();
}

class _MarkStaffAttendanceScreenState extends ConsumerState<MarkStaffAttendanceScreen> {
  DateTime _date = DateTime.now();
  String _query = '';
  final Set<String> _savingKeys = {};

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

  Future<void> _mark(AttendanceRosterEntry entry, String status) async {
    final key = '${entry.type}:${entry.id}';
    setState(() => _savingKeys.add(key));

    final request = StaffAttendanceMarkRequest(
      staffId: entry.type == 'staff' ? entry.id : null,
      teacherId: entry.type == 'teacher' ? entry.id : null,
      date: _date,
      status: status,
    );

    try {
      await ref.read(staffAttendanceRepositoryProvider).markAttendance(request);
      if (!mounted) return;
      setState(() {
        entry.markedStatus = status;
        _savingKeys.remove(key);
      });
      ref.invalidate(staffAttendanceListControllerProvider(date: _date));
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingKeys.remove(key));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark ${entry.name}: ${friendlyErrorMessage(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(allStaffListControllerProvider);
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final attendanceAsync = ref.watch(staffAttendanceListControllerProvider(date: _date));

    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date'),
                      child: Text(_fmt(_date)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: staffAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Failed to load staff: ${friendlyErrorMessage(e)}')),
              data: (staffList) => teachersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Failed to load teachers: ${friendlyErrorMessage(e)}')),
                data: (teacherList) => attendanceAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Failed to load attendance: ${friendlyErrorMessage(e)}')),
                  data: (records) {
                    final markedByKey = {
                      for (final r in records)
                        (r.personType == 'staff' ? 'staff:${r.staffId}' : 'teacher:${r.teacherId}'):
                            r.status,
                    };

                    var roster = [
                      ...staffList.map((s) => AttendanceRosterEntry(
                            id: s.id,
                            name: s.fullName,
                            type: 'staff',
                            markedStatus: markedByKey['staff:${s.id}'],
                          )),
                      ...teacherList.map((t) => AttendanceRosterEntry(
                            id: t.id,
                            name: t.fullName,
                            type: 'teacher',
                            markedStatus: markedByKey['teacher:${t.id}'],
                          )),
                    ]..sort((a, b) => a.name.compareTo(b.name));

                    if (_query.isNotEmpty) {
                      final q = _query.toLowerCase();
                      roster = roster.where((e) => e.name.toLowerCase().contains(q)).toList();
                    }

                    if (roster.isEmpty) {
                      return const Center(child: Text('No staff or teachers found'));
                    }

                    return ListView.separated(
                      itemCount: roster.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = roster[index];
                        final key = '${entry.type}:${entry.id}';
                        final isSaving = _savingKeys.contains(key);
                        final isLocked = entry.markedStatus != null;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(
                                      entry.type == 'staff' ? 'Staff' : 'Teacher',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: isSaving
                                    ? const Center(
                                        child: SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      )
                                    : Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: attendanceStatusOptions.map((opt) {
                                          final selected = entry.markedStatus == opt['value'];
                                          return ChoiceChip(
                                            label: Text(opt['label']!,
                                                style: const TextStyle(fontSize: 12)),
                                            selected: selected,
                                            onSelected:
                                                isLocked ? null : (_) => _mark(entry, opt['value']!),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}