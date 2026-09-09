import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/staff/application/all_staff_list_controller.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import '../../application/staff_attendance_list_controller.dart';
import '../../application/bulk_mark_staff_attendance_controller.dart';
import '../../data/models/bulk_staff_attendance_entry.dart';
import '../../data/models/bulk_staff_attendance_request.dart';
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
  List<AttendanceRosterEntry>? _roster;

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
        _roster = null; // force rebuild from fresh data for the new date
      });
    }
  }

  void _markAllUnmarkedPresent() {
    if (_roster == null) return;
    setState(() {
      for (final entry in _roster!) {
        if (entry.originalStatus == null && entry.localStatus == null) {
          entry.localStatus = 'present';
        }
      }
    });
  }

  Future<void> _saveChanges() async {
    final dirty = _roster?.where((e) => e.isDirty && e.localStatus != null).toList() ?? [];
    if (dirty.isEmpty) return;

    final request = BulkStaffAttendanceRequest(
      date: _date,
      entries: dirty
          .map((e) => BulkStaffAttendanceEntry(
                staffId: e.type == 'staff' ? e.id : null,
                teacherId: e.type == 'teacher' ? e.id : null,
                status: e.localStatus!,
              ))
          .toList(),
    );

    final result = await ref.read(bulkMarkStaffAttendanceControllerProvider.notifier).submit(request);
    if (!mounted) return;

    if (result == null) {
      final error = ref.read(bulkMarkStaffAttendanceControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save: ${error != null ? friendlyErrorMessage(error) : 'Unknown error'}'),
      ));
      return;
    }

    final skipped = result.results.where((r) => r.action == 'skipped_duplicate').length;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Saved ${result.results.length - skipped} record(s)'
        '${skipped > 0 ? ', $skipped skipped' : ''}',
      ),
    ));

    ref.invalidate(staffAttendanceListControllerProvider(date: _date));
    setState(() => _roster = null); // reload fresh original state for this date
  }

  List<AttendanceRosterEntry> _buildRoster(
    List staffList,
    List teacherList,
    List records,
  ) {
    final statusByKey = {
      for (final r in records)
        (r.personType == 'staff' ? 'staff:${r.staffId}' : 'teacher:${r.teacherId}'): r.status,
    };

    final roster = [
      ...staffList.map((s) => AttendanceRosterEntry(
            id: s.id,
            name: s.fullName,
            type: 'staff',
            originalStatus: statusByKey['staff:${s.id}'],
          )),
      ...teacherList.map((t) => AttendanceRosterEntry(
            id: t.id,
            name: t.fullName,
            type: 'teacher',
            originalStatus: statusByKey['teacher:${t.id}'],
          )),
    ]..sort((a, b) => a.name.compareTo(b.name));

    return roster;
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(allStaffListControllerProvider);
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final attendanceAsync = ref.watch(staffAttendanceListControllerProvider(date: _date));
    final submitState = ref.watch(bulkMarkStaffAttendanceControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all unmarked as Present',
            onPressed: _roster == null ? null : _markAllUnmarkedPresent,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(_fmt(_date)),
              ),
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
                    // Build the roster once per date (preserves in-progress local
                    // selections across rebuilds caused by typing in the search box).
                    _roster ??= _buildRoster(staffList, teacherList, records);

                    var visible = _roster!;
                    if (_query.isNotEmpty) {
                      final q = _query.toLowerCase();
                      visible = visible.where((e) => e.name.toLowerCase().contains(q)).toList();
                    }

                    if (visible.isEmpty) {
                      return const Center(child: Text('No staff or teachers found'));
                    }

                    return ListView.separated(
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = visible[index];
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
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(entry.name,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        if (entry.isDirty)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 4),
                                            child: Icon(Icons.circle, size: 8, color: Colors.orange),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      entry.type == 'staff' ? 'Staff' : 'Teacher',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: attendanceStatusOptions.map((opt) {
                                    final selected = entry.localStatus == opt['value'];
                                    return ChoiceChip(
                                      label:
                                          Text(opt['label']!, style: const TextStyle(fontSize: 12)),
                                      selected: selected,
                                      onSelected: (_) => setState(() => entry.localStatus =
                                          selected ? null : opt['value']),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: submitState.isLoading ? null : _saveChanges,
            child: submitState.isLoading
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    'Save Changes'
                    '${_roster != null && _roster!.any((e) => e.isDirty) ? ' (${_roster!.where((e) => e.isDirty).length})' : ''}',
                  ),
          ),
        ),
      ),
    );
  }
}