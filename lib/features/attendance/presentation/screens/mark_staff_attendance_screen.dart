import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/bulk_mark_staff_attendance_controller.dart';
import '../../application/mark_staff_attendance_controller.dart';
import '../../application/staff_attendance_list_controller.dart';
import '../../data/models/bulk_staff_attendance_entry.dart';
import '../../data/models/bulk_staff_attendance_request.dart';
import '../../data/models/staff_attendance_mark_request.dart';
import '../../data/models/staff_attendance_unified_models.dart';
import '../widgets/staff_attendance_dialogs.dart';
import 'staff_attendance_list_screen.dart';

enum _RosterRowMode { checkInOut, absent, leave }

enum _RosterFilter { all, teachers, staff, unmarked, marked }

class _RowDraft {
  _RosterRowMode mode = _RosterRowMode.checkInOut;
  TimeOfDay? checkInOverride;
  TimeOfDay? checkOutOverride;
  bool clearExistingCheckOut = false;
  bool? shortLeaveOverride;
}

class MarkStaffAttendanceScreen extends ConsumerStatefulWidget {
  final bool isPrincipalReadOnly;

  const MarkStaffAttendanceScreen({
    super.key,
    this.isPrincipalReadOnly = false,
  });

  @override
  ConsumerState<MarkStaffAttendanceScreen> createState() =>
      _MarkStaffAttendanceScreenState();
}

class _MarkStaffAttendanceScreenState
    extends ConsumerState<MarkStaffAttendanceScreen> {
  DateTime _date = DateTime.now();
  _RosterFilter _filter = _RosterFilter.all;
  String _search = '';
  TimeOfDay? _defaultCheckIn = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _defaultCheckOut;
  final TextEditingController _reasonCtrl = TextEditingController();
  final Set<String> _selectedKeys = <String>{};
  final Map<String, _RowDraft> _drafts = <String, _RowDraft>{};
  String? _savingRowKey;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  _RowDraft _draftFor(StaffAttendanceRosterItem item) {
    return _drafts.putIfAbsent(item.rosterKey, () {
      final d = _RowDraft();
      if (item.isMarked) {
        if (item.status == 'absent') {
          d.mode = _RosterRowMode.absent;
        } else if (item.status == 'leave') {
          d.mode = _RosterRowMode.leave;
        } else {
          d.mode = _RosterRowMode.checkInOut;
        }
        if (item.checkInAt != null) {
          final local = item.checkInAt!.toLocal();
          d.checkInOverride = TimeOfDay(hour: local.hour, minute: local.minute);
        }
        if (item.checkOutAt != null) {
          final local = item.checkOutAt!.toLocal();
          d.checkOutOverride = TimeOfDay(
            hour: local.hour,
            minute: local.minute,
          );
        }
        d.shortLeaveOverride = item.shortLeave ? true : null;
      }
      return d;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _selectedKeys.clear();
      _drafts.clear();
    });
  }

  Future<void> _pickDefaultTime({required bool isCheckIn}) async {
    final initial =
        (isCheckIn ? _defaultCheckIn : _defaultCheckOut) ??
        TimeOfDay(hour: isCheckIn ? 8 : 14, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _defaultCheckIn = picked;
      } else {
        _defaultCheckOut = picked;
      }
    });
  }

  Future<void> _pickRowTime(
    StaffAttendanceRosterItem item, {
    required bool isCheckIn,
  }) async {
    final draft = _draftFor(item);
    final initial =
        (isCheckIn
            ? (draft.checkInOverride ?? _defaultCheckIn)
            : (draft.checkOutOverride ?? _defaultCheckOut)) ??
        TimeOfDay(hour: isCheckIn ? 8 : 14, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      draft.mode = _RosterRowMode.checkInOut;
      if (isCheckIn) {
        draft.checkInOverride = picked;
      } else {
        draft.checkOutOverride = picked;
        draft.clearExistingCheckOut = false;
      }
    });
  }

  List<StaffAttendanceRosterItem> _applyFilters(
    List<StaffAttendanceRosterItem> items,
  ) {
    final q = _search.trim().toLowerCase();
    return items.where((item) {
      if (q.isNotEmpty) {
        final hay =
            '${item.personName} ${item.designation ?? ''} ${item.personType}'
                .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return switch (_filter) {
        _RosterFilter.all => true,
        _RosterFilter.teachers => item.personType == 'teacher',
        _RosterFilter.staff => item.personType == 'staff',
        _RosterFilter.unmarked => !item.isMarked,
        _RosterFilter.marked => item.isMarked,
      };
    }).toList();
  }

  Future<void> _saveSingleRow(StaffAttendanceRosterItem item) async {
    if (widget.isPrincipalReadOnly) return;
    final draft = _draftFor(item);
    final dateIso = formatApiDate(_date);

    late StaffAttendanceMarkRequest req;
    if (draft.mode == _RosterRowMode.absent ||
        draft.mode == _RosterRowMode.leave) {
      req = StaffAttendanceMarkRequest(
        personType: item.personType,
        personId: item.personId,
        date: dateIso,
        status: draft.mode == _RosterRowMode.absent ? 'absent' : 'leave',
        reason: _reasonCtrl.text.trim().isEmpty
            ? null
            : _reasonCtrl.text.trim(),
      );
    } else {
      final checkInTod = draft.checkInOverride ?? _defaultCheckIn;
      final checkOutTod = draft.clearExistingCheckOut
          ? null
          : (draft.checkOutOverride ?? _defaultCheckOut);
      if (checkInTod == null) {
        _showSnack(
          'Set a Check-In time for ${item.personName}.',
          isError: true,
        );
        return;
      }
      final checkInDt = combineLocalDateAndTime(_date, checkInTod);
      final checkOutDt = checkOutTod != null
          ? combineLocalDateAndTime(_date, checkOutTod)
          : null;
      if (checkOutDt != null && checkOutDt.isBefore(checkInDt)) {
        _showSnack(
          'Check-Out cannot be earlier than Check-In for ${item.personName}.',
          isError: true,
        );
        return;
      }
      req = StaffAttendanceMarkRequest(
        personType: item.personType,
        personId: item.personId,
        date: dateIso,
        checkInAt: checkInDt,
        checkOutAt: checkOutDt,
        shortLeave: draft.shortLeaveOverride,
        reason: _reasonCtrl.text.trim().isEmpty
            ? null
            : _reasonCtrl.text.trim(),
      );
    }

    setState(() => _savingRowKey = item.rosterKey);
    final saved = await ref
        .read(markStaffAttendanceControllerProvider.notifier)
        .markAttendance(req);
    if (!mounted) return;
    setState(() => _savingRowKey = null);

    if (saved != null) {
      _drafts.remove(item.rosterKey);
      _showSnack('Saved attendance for ${item.personName} (${saved.status}).');
    } else {
      final err = ref.read(markStaffAttendanceControllerProvider).error;
      _showSnack(
        err != null ? friendlyErrorMessage(err) : 'Failed to save attendance.',
        isError: true,
      );
    }
  }

  Future<void> _submitBulk(List<StaffAttendanceRosterItem> roster) async {
    if (widget.isPrincipalReadOnly) return;
    if (_selectedKeys.isEmpty) {
      _showSnack('Select at least one teacher or staff member.', isError: true);
      return;
    }

    final byKey = {for (final r in roster) r.rosterKey: r};
    final entries = <BulkStaffAttendanceEntry>[];

    for (final key in _selectedKeys) {
      final item = byKey[key];
      if (item == null) continue;
      final draft = _draftFor(item);
      if (draft.mode == _RosterRowMode.absent ||
          draft.mode == _RosterRowMode.leave) {
        entries.add(
          BulkStaffAttendanceEntry(
            personType: item.personType,
            personId: item.personId,
            status: draft.mode == _RosterRowMode.absent ? 'absent' : 'leave',
          ),
        );
      } else {
        final effectiveIn = draft.checkInOverride ?? _defaultCheckIn;
        if (effectiveIn == null) {
          _showSnack(
            'Provide a Check-In time (or Default Check-In) for ${item.personName}.',
            isError: true,
          );
          return;
        }
        final effectiveOut = draft.clearExistingCheckOut
            ? null
            : (draft.checkOutOverride ?? _defaultCheckOut);
        final inDt = combineLocalDateAndTime(_date, effectiveIn);
        final outDt = effectiveOut != null
            ? combineLocalDateAndTime(_date, effectiveOut)
            : null;
        if (outDt != null && outDt.isBefore(inDt)) {
          _showSnack(
            'Check-Out cannot be earlier than Check-In for ${item.personName}.',
            isError: true,
          );
          return;
        }

        entries.add(
          BulkStaffAttendanceEntry(
            personType: item.personType,
            personId: item.personId,
            checkInAt: draft.checkInOverride != null ? inDt : null,
            checkOutAt: draft.checkOutOverride != null ? outDt : null,
            shortLeave: draft.shortLeaveOverride,
          ),
        );
      }
    }

    if (entries.isEmpty) return;

    final req = BulkStaffAttendanceRequest(
      date: formatApiDate(_date),
      defaultCheckInAt: _defaultCheckIn != null
          ? combineLocalDateAndTime(_date, _defaultCheckIn!)
          : null,
      defaultCheckOutAt: _defaultCheckOut != null
          ? combineLocalDateAndTime(_date, _defaultCheckOut!)
          : null,
      reason: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
      entries: entries,
    );

    final result = await ref
        .read(bulkMarkStaffAttendanceControllerProvider.notifier)
        .submit(req);

    if (!mounted) return;
    if (result != null) {
      setState(() {
        _selectedKeys.clear();
        _drafts.clear();
      });
      _showSnack('Saved ${result.savedCount} attendance record(s).');
    } else {
      final err = ref.read(bulkMarkStaffAttendanceControllerProvider).error;
      _showSnack(
        err != null
            ? friendlyErrorMessage(err)
            : 'Bulk save failed. No records were saved.',
        isError: true,
      );
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFB91C1C) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateIso = formatApiDate(_date);
    final rosterAsync = ref.watch(staffAttendanceRosterProvider(dateIso));
    final bulkState = ref.watch(bulkMarkStaffAttendanceControllerProvider);
    final singleState = ref.watch(markStaffAttendanceControllerProvider);
    final isBusy = bulkState.isLoading || singleState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff & Teacher Check-In / Out'),
        backgroundColor: const Color(0xFFF5DCD7),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StaffAttendanceListScreen(
                  isPrincipalReadOnly: widget.isPrincipalReadOnly,
                ),
              ),
            ),
            icon: const Icon(Icons.analytics_outlined, size: 18),
            label: const Text('Records & Summary'),
          ),
          IconButton(
            tooltip: 'Refresh Roster',
            onPressed: () {
              _drafts.clear();
              ref.invalidate(staffAttendanceRosterProvider(dateIso));
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: CampusBackground()),
          SafeArea(
            child: rosterAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Failed to load unified roster: ${friendlyErrorMessage(e)}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(
                          staffAttendanceRosterProvider(dateIso),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (roster) {
                final filtered = _applyFilters(roster);
                final markedCount = roster.where((r) => r.isMarked).length;
                final unmarkedCount = roster.length - markedCount;
                final presentCount = roster
                    .where((r) => r.isMarked && r.status == 'present')
                    .length;
                final lateCount = roster
                    .where((r) => r.isMarked && r.status == 'late')
                    .length;

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _drafts.clear();
                          ref.invalidate(
                            staffAttendanceRosterProvider(dateIso),
                          );
                        },
                        child: ListView(
                          padding: EdgeInsets.all(
                            MediaQuery.sizeOf(context).width < 520 ? 14 : 20,
                          ),
                          children: [
                            if (widget.isPrincipalReadOnly)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.visibility_outlined,
                                      color: Color(0xFFB45309),
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Principal Read-Only View: You can inspect the unified roster, audit logs, and history, while marking/editing is restricted to Management.',
                                        style: TextStyle(
                                          color: Color(0xFF92400E),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _buildTopControlsCard(
                              dateIso: dateIso,
                              total: roster.length,
                              marked: markedCount,
                              unmarked: unmarkedCount,
                              present: presentCount,
                              late: lateCount,
                            ),
                            if (!widget.isPrincipalReadOnly) ...[
                              const SizedBox(height: 12),
                              _buildBulkDefaultsCard(filtered, isBusy),
                            ],
                            const SizedBox(height: 12),
                            if (filtered.isEmpty)
                              CampusCard(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 28,
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.person_search_rounded,
                                        size: 38,
                                        color: CampusStyle.muted,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        roster.isEmpty
                                            ? 'No active teachers or staff eligible on $dateIso.'
                                            : 'No roster members match your current filter.',
                                        style: const TextStyle(
                                          color: CampusStyle.muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...filtered.map(
                                (item) => _buildRosterRowCard(
                                  item,
                                  dateIso: dateIso,
                                  isBusy: isBusy,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (!widget.isPrincipalReadOnly && _selectedKeys.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: CampusStyle.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${_selectedKeys.length} selected for $dateIso',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CampusStyle.ink,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: isBusy
                                    ? null
                                    : () => setState(_selectedKeys.clear),
                                child: const Text('Clear'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: isBusy
                                    ? null
                                    : () => _submitBulk(roster),
                                icon: bulkState.isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save_rounded),
                                label: Text(
                                  'Submit Selected (${_selectedKeys.length})',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControlsCard({
    required String dateIso,
    required int total,
    required int marked,
    required int unmarked,
    required int present,
    required int late,
  }) {
    return CampusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_rounded, size: 17),
                label: Text('Date: $dateIso'),
              ),
              SizedBox(
                width: 240,
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: const InputDecoration(
                    hintText: 'Search teacher or staff...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChipItem(
                label: 'All ($total)',
                selected: _filter == _RosterFilter.all,
                onTap: () => setState(() => _filter = _RosterFilter.all),
              ),
              _FilterChipItem(
                label: 'Teachers',
                selected: _filter == _RosterFilter.teachers,
                onTap: () => setState(() => _filter = _RosterFilter.teachers),
              ),
              _FilterChipItem(
                label: 'Non-Teaching Staff',
                selected: _filter == _RosterFilter.staff,
                onTap: () => setState(() => _filter = _RosterFilter.staff),
              ),
              _FilterChipItem(
                label: 'Not Marked ($unmarked)',
                selected: _filter == _RosterFilter.unmarked,
                onTap: () => setState(() => _filter = _RosterFilter.unmarked),
              ),
              _FilterChipItem(
                label: 'Marked ($marked)',
                selected: _filter == _RosterFilter.marked,
                onTap: () => setState(() => _filter = _RosterFilter.marked),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _KpiPill('Total: $total', const Color(0xFF475569)),
              _KpiPill('Present: $present', const Color(0xFF15803D)),
              _KpiPill('Late: $late', const Color(0xFFB45309)),
              _KpiPill('Not marked: $unmarked', const Color(0xFF64748B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkDefaultsCard(
    List<StaffAttendanceRosterItem> filtered,
    bool isBusy,
  ) {
    return CampusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bulk Check-In / Out Defaults',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: CampusStyle.ink,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Applies to selected rows unless overridden per row. Absent / Leave rows ignore timestamps automatically.',
            style: TextStyle(color: CampusStyle.muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy
                    ? null
                    : () => _pickDefaultTime(isCheckIn: true),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: Text(
                  'Default In: ${_defaultCheckIn != null ? formatTimeOfDay12h(_defaultCheckIn!) : 'Not set'}',
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () => _pickDefaultTime(isCheckIn: false),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text(
                      'Default Out: ${_defaultCheckOut != null ? formatTimeOfDay12h(_defaultCheckOut!) : 'Optional'}',
                    ),
                  ),
                  if (_defaultCheckOut != null)
                    IconButton(
                      tooltip: 'Clear default check-out',
                      onPressed: isBusy
                          ? null
                          : () => setState(() => _defaultCheckOut = null),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                ],
              ),
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _reasonCtrl,
                  enabled: !isBusy,
                  decoration: const InputDecoration(
                    labelText: 'Note / Reason (optional)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: isBusy || filtered.isEmpty
                    ? null
                    : () => setState(() {
                        _selectedKeys.addAll(filtered.map((e) => e.rosterKey));
                      }),
                icon: const Icon(Icons.select_all_rounded, size: 18),
                label: const Text('Select Visible'),
              ),
              TextButton.icon(
                onPressed: isBusy || filtered.isEmpty
                    ? null
                    : () => setState(() {
                        _selectedKeys.addAll(
                          filtered
                              .where((e) => !e.isMarked)
                              .map((e) => e.rosterKey),
                        );
                      }),
                icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                label: const Text('Select Not Marked'),
              ),
              if (_selectedKeys.isNotEmpty)
                TextButton.icon(
                  onPressed: isBusy
                      ? null
                      : () => setState(_selectedKeys.clear),
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: const Text('Clear Selection'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRosterRowCard(
    StaffAttendanceRosterItem item, {
    required String dateIso,
    required bool isBusy,
  }) {
    final draft = _draftFor(item);
    final selected = _selectedKeys.contains(item.rosterKey);
    final rowSaving = _savingRowKey == item.rosterKey;
    final roleTag = item.isTeacher
        ? 'Teacher'
        : (item.designation?.isNotEmpty == true ? item.designation! : 'Staff');

    final effectiveIn = draft.checkInOverride ?? _defaultCheckIn;
    final effectiveOut = draft.clearExistingCheckOut
        ? null
        : (draft.checkOutOverride ?? _defaultCheckOut);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? CampusStyle.primary : const Color(0xFFF5DCD7),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isPrincipalReadOnly)
                  Checkbox(
                    value: selected,
                    onChanged: isBusy
                        ? null
                        : (v) {
                            setState(() {
                              if (v == true) {
                                _selectedKeys.add(item.rosterKey);
                              } else {
                                _selectedKeys.remove(item.rosterKey);
                              }
                            });
                          },
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            item.personName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: CampusStyle.ink,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.isTeacher
                                  ? const Color(0xFFEDE9FE)
                                  : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              roleTag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: item.isTeacher
                                    ? const Color(0xFF5B21B6)
                                    : const Color(0xFF0369A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      StaffAttendanceStatusBadge(
                        status: item.status,
                        isMarked: item.isMarked,
                        shortLeave: item.shortLeave,
                        checkInSource: item.checkInSource,
                        checkOutSource: item.checkOutSource,
                      ),
                      if (item.isMarked) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Saved: In ${formatLocalTime(item.checkInAt)}  •  Out ${formatLocalTime(item.checkOutAt)}',
                          style: const TextStyle(
                            color: CampusStyle.muted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Person History',
                      onPressed: () {
                        final now = DateTime.now();
                        showStaffPersonHistoryDialog(
                          context: context,
                          personType: item.personType,
                          personId: item.personId,
                          personName: item.personName,
                          dateFrom: now.subtract(const Duration(days: 30)),
                          dateTo: now,
                          isPrincipalReadOnly: widget.isPrincipalReadOnly,
                        );
                      },
                      icon: const Icon(Icons.person_search_outlined, size: 20),
                    ),
                    if (item.isMarked && item.attendanceId != null)
                      IconButton(
                        tooltip: 'Audit Log',
                        onPressed: () => showStaffAttendanceAuditDialog(
                          context: context,
                          attendanceId: item.attendanceId!,
                          personName: item.personName,
                          dateIso: dateIso,
                        ),
                        icon: const Icon(Icons.history_rounded, size: 20),
                      ),
                    if (!widget.isPrincipalReadOnly &&
                        item.isMarked &&
                        item.attendanceId != null)
                      IconButton(
                        tooltip: 'Edit with Reason',
                        onPressed: isBusy
                            ? null
                            : () async {
                                final updated =
                                    await showEditStaffAttendanceDialog(
                                      context: context,
                                      attendanceId: item.attendanceId!,
                                      personName: item.personName,
                                      personType: item.personType,
                                      dateIso: dateIso,
                                      initialStatus: item.status,
                                      initialCheckIn: item.checkInAt,
                                      initialCheckOut: item.checkOutAt,
                                      initialShortLeave: item.shortLeave,
                                    );
                                if (updated != null && mounted) {
                                  _drafts.remove(item.rosterKey);
                                  _showSnack(
                                    'Updated ${item.personName} (${updated.status}).',
                                  );
                                }
                              },
                        icon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                  ],
                ),
              ],
            ),
            if (!widget.isPrincipalReadOnly) ...[
              const Divider(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Check-In / Out'),
                    selected: draft.mode == _RosterRowMode.checkInOut,
                    onSelected: isBusy
                        ? null
                        : (_) => setState(
                            () => draft.mode = _RosterRowMode.checkInOut,
                          ),
                  ),
                  ChoiceChip(
                    label: const Text('Absent'),
                    selected: draft.mode == _RosterRowMode.absent,
                    onSelected: isBusy
                        ? null
                        : (_) => setState(
                            () => draft.mode = _RosterRowMode.absent,
                          ),
                  ),
                  ChoiceChip(
                    label: const Text('Leave'),
                    selected: draft.mode == _RosterRowMode.leave,
                    onSelected: isBusy
                        ? null
                        : (_) =>
                              setState(() => draft.mode = _RosterRowMode.leave),
                  ),
                  if (draft.mode == _RosterRowMode.checkInOut) ...[
                    OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () => _pickRowTime(item, isCheckIn: true),
                      icon: const Icon(Icons.login_rounded, size: 16),
                      label: Text(
                        'In: ${effectiveIn != null ? formatTimeOfDay12h(effectiveIn) : 'Set'}',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () => _pickRowTime(item, isCheckIn: false),
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: Text(
                        'Out: ${effectiveOut != null ? formatTimeOfDay12h(effectiveOut) : 'Optional'}',
                      ),
                    ),
                    FilterChip(
                      label: const Text('Short Leave'),
                      selected: draft.shortLeaveOverride == true,
                      onSelected: isBusy
                          ? null
                          : (v) => setState(
                              () => draft.shortLeaveOverride = v ? true : null,
                            ),
                    ),
                  ],
                  FilledButton.tonalIcon(
                    onPressed: isBusy ? null : () => _saveSingleRow(item),
                    icon: rowSaving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded, size: 17),
                    label: Text(item.isMarked ? 'Update Row' : 'Save Row'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _KpiPill extends StatelessWidget {
  final String text;
  final Color color;

  const _KpiPill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
