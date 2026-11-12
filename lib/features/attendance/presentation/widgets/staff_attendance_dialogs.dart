import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/mark_staff_attendance_controller.dart';
import '../../application/staff_attendance_list_controller.dart';
import '../../data/models/staff_attendance.dart';
import '../../data/models/staff_attendance_unified_models.dart';

class CampusCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CampusCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: CampusStyle.card,
      child: child,
    );
  }
}

/// Shared pill badge for unified teacher & staff attendance status.
/// Never shows "Absent" when [isMarked] is false — always shows "Not marked".
class StaffAttendanceStatusBadge extends StatelessWidget {
  final String? status;
  final bool isMarked;
  final bool shortLeave;
  final String? checkInSource;
  final String? checkOutSource;

  const StaffAttendanceStatusBadge({
    super.key,
    required this.status,
    required this.isMarked,
    this.shortLeave = false,
    this.checkInSource,
    this.checkOutSource,
  });

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = !isMarked
        ? ('Not marked', const Color(0xFF64748B))
        : switch (status) {
            'present' => ('Present', const Color(0xFF15803D)),
            'late' => ('Late', const Color(0xFFB45309)),
            'absent' => ('Absent', const Color(0xFFB91C1C)),
            'leave' => ('Leave', const Color(0xFF5B21B6)),
            _ => (status ?? 'Unknown', const Color(0xFF475569)),
          };

    final sourceLabel = _combinedSourceLabel();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _StatusChip(label: label, color: color),
        if (isMarked && shortLeave)
          const _StatusChip(label: 'Short Leave', color: Color(0xFFD97706)),
        if (isMarked && sourceLabel != null)
          _StatusChip(label: sourceLabel, color: const Color(0xFF334155)),
      ],
    );
  }

  String? _combinedSourceLabel() {
    final sources = <String>{
      if (checkInSource != null && checkInSource!.isNotEmpty) checkInSource!,
      if (checkOutSource != null && checkOutSource!.isNotEmpty) checkOutSource!,
    };
    if (sources.isEmpty) return null;
    if (sources.length == 1) {
      return sources.first == 'biometric' ? 'Biometric' : 'Manual';
    }
    return 'Bio / Manual';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum StaffEditMode { checkInOut, absent, leave }

/// Opens the Edit Saved Attendance modal (`PATCH /attendance/staff/{id}`).
/// Requires a reason (3–500 chars) and supports editing timestamps, clearing
/// timestamps, overriding short_leave, or switching to Absent / Leave.
Future<StaffAttendance?> showEditStaffAttendanceDialog({
  required BuildContext context,
  required String attendanceId,
  required String personName,
  required String personType,
  required String dateIso,
  required String? initialStatus,
  required DateTime? initialCheckIn,
  required DateTime? initialCheckOut,
  required bool initialShortLeave,
}) {
  return showDialog<StaffAttendance>(
    context: context,
    builder: (_) => _EditStaffAttendanceDialog(
      attendanceId: attendanceId,
      personName: personName,
      personType: personType,
      dateIso: dateIso,
      initialStatus: initialStatus,
      initialCheckIn: initialCheckIn,
      initialCheckOut: initialCheckOut,
      initialShortLeave: initialShortLeave,
    ),
  );
}

class _EditStaffAttendanceDialog extends ConsumerStatefulWidget {
  final String attendanceId;
  final String personName;
  final String personType;
  final String dateIso;
  final String? initialStatus;
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;
  final bool initialShortLeave;

  const _EditStaffAttendanceDialog({
    required this.attendanceId,
    required this.personName,
    required this.personType,
    required this.dateIso,
    required this.initialStatus,
    required this.initialCheckIn,
    required this.initialCheckOut,
    required this.initialShortLeave,
  });

  @override
  ConsumerState<_EditStaffAttendanceDialog> createState() =>
      _EditStaffAttendanceDialogState();
}

class _EditStaffAttendanceDialogState
    extends ConsumerState<_EditStaffAttendanceDialog> {
  late StaffEditMode _mode;
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  bool _clearCheckIn = false;
  bool _clearCheckOut = false;
  bool? _shortLeaveOverride; // null = policy auto
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  DateTime get _parsedDate => DateTime.tryParse(widget.dateIso) ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialStatus == 'absent') {
      _mode = StaffEditMode.absent;
    } else if (widget.initialStatus == 'leave') {
      _mode = StaffEditMode.leave;
    } else {
      _mode = StaffEditMode.checkInOut;
    }
    if (widget.initialCheckIn != null) {
      final local = widget.initialCheckIn!.toLocal();
      _checkInTime = TimeOfDay(hour: local.hour, minute: local.minute);
    }
    if (widget.initialCheckOut != null) {
      final local = widget.initialCheckOut!.toLocal();
      _checkOutTime = TimeOfDay(hour: local.hour, minute: local.minute);
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isCheckIn}) async {
    final initial = (isCheckIn ? _checkInTime : _checkOutTime) ??
        TimeOfDay(hour: isCheckIn ? 8 : 14, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkInTime = picked;
        _clearCheckIn = false;
      } else {
        _checkOutTime = picked;
        _clearCheckOut = false;
      }
      _error = null;
    });
  }

  Future<void> _submit() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.length < 3 || reason.length > 500) {
      setState(() {
        _error = 'Reason must be between 3 and 500 characters.';
      });
      return;
    }

    late StaffAttendanceEditRequest req;
    if (_mode == StaffEditMode.absent || _mode == StaffEditMode.leave) {
      req = StaffAttendanceEditRequest(
        status: _mode == StaffEditMode.absent ? 'absent' : 'leave',
        reason: reason,
      );
    } else {
      if (_checkInTime == null && _checkOutTime == null) {
        setState(() {
          _error = 'Select at least a Check-In time (or choose Absent / Leave).';
        });
        return;
      }
      final date = _parsedDate;
      final checkInDt = _checkInTime != null
          ? combineLocalDateAndTime(date, _checkInTime!)
          : null;
      final checkOutDt = _checkOutTime != null
          ? combineLocalDateAndTime(date, _checkOutTime!)
          : null;

      if (checkInDt != null &&
          checkOutDt != null &&
          checkOutDt.isBefore(checkInDt)) {
        setState(() {
          _error = 'Check-Out time cannot be earlier than Check-In time.';
        });
        return;
      }

      req = StaffAttendanceEditRequest(
        checkInAt: checkInDt,
        clearCheckIn: _clearCheckIn && widget.initialCheckIn != null,
        checkOutAt: checkOutDt,
        clearCheckOut: _clearCheckOut && widget.initialCheckOut != null,
        shortLeave: _shortLeaveOverride,
        reason: reason,
      );
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final result = await ref
        .read(markStaffAttendanceControllerProvider.notifier)
        .editAttendance(attendanceId: widget.attendanceId, request: req);

    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(result);
    } else {
      final err = ref.read(markStaffAttendanceControllerProvider).error;
      setState(() {
        _saving = false;
        _error = err != null
            ? friendlyErrorMessage(err)
            : 'Failed to update attendance record.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = widget.personType == 'teacher' ? 'Teacher' : 'Staff';
    return AlertDialog(
      title: Text('Edit Attendance • ${widget.personName}'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$roleLabel • ${widget.dateIso}',
                style: const TextStyle(color: CampusStyle.muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              SegmentedButton<StaffEditMode>(
                segments: const [
                  ButtonSegment(
                    value: StaffEditMode.checkInOut,
                    label: Text('Check-In / Out'),
                  ),
                  ButtonSegment(
                    value: StaffEditMode.absent,
                    label: Text('Absent'),
                  ),
                  ButtonSegment(
                    value: StaffEditMode.leave,
                    label: Text('Leave'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: _saving
                    ? null
                    : (s) => setState(() {
                          _mode = s.first;
                          _error = null;
                        }),
              ),
              const SizedBox(height: 14),
              if (_mode == StaffEditMode.checkInOut) ...[
                _TimeFieldRow(
                  label: 'Check-In Time',
                  value: _checkInTime != null
                      ? formatTimeOfDay12h(_checkInTime!)
                      : 'Not set',
                  onPick: _saving ? null : () => _pickTime(isCheckIn: true),
                  onClear: _saving || _checkInTime == null
                      ? null
                      : () => setState(() {
                            _checkInTime = null;
                            _clearCheckIn = true;
                          }),
                ),
                const SizedBox(height: 10),
                _TimeFieldRow(
                  label: 'Check-Out Time',
                  value: _checkOutTime != null
                      ? formatTimeOfDay12h(_checkOutTime!)
                      : 'Not set',
                  onPick: _saving ? null : () => _pickTime(isCheckIn: false),
                  onClear: _saving || _checkOutTime == null
                      ? null
                      : () => setState(() {
                            _checkOutTime = null;
                            _clearCheckOut = true;
                          }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<bool?>(
                  initialValue: _shortLeaveOverride,
                  decoration: const InputDecoration(
                    labelText: 'Short Leave Override',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Auto (Policy)')),
                    DropdownMenuItem(value: true, child: Text('Mark Short Leave')),
                    DropdownMenuItem(value: false, child: Text('Clear Short Leave')),
                  ],
                  onChanged: _saving
                      ? null
                      : (v) => setState(() => _shortLeaveOverride = v),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Text(
                    'Timestamps and short leave will be cleared automatically when saving as Absent or Leave.',
                    style: TextStyle(color: Color(0xFF991B1B), fontSize: 12.5),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: _reasonCtrl,
                enabled: !_saving,
                maxLines: 2,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Audit Reason * (3–500 chars)',
                  hintText: 'e.g., Added missing departure time',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _TimeFieldRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onPick;
  final VoidCallback? onClear;

  const _TimeFieldRow({
    required this.label,
    required this.value,
    this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6FD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2DAF3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: CampusStyle.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CampusStyle.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.schedule_rounded, size: 18),
            label: const Text('Set'),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              tooltip: 'Clear time',
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}

/// Opens Audit Trail dialog (`GET /attendance/staff/{attendance_id}/audit`).
Future<void> showStaffAttendanceAuditDialog({
  required BuildContext context,
  required String attendanceId,
  required String personName,
  required String dateIso,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _StaffAttendanceAuditDialog(
      attendanceId: attendanceId,
      personName: personName,
      dateIso: dateIso,
    ),
  );
}

class _StaffAttendanceAuditDialog extends ConsumerWidget {
  final String attendanceId;
  final String personName;
  final String dateIso;

  const _StaffAttendanceAuditDialog({
    required this.attendanceId,
    required this.personName,
    required this.dateIso,
  });

  String _formatSnapshot(Map<String, dynamic>? snap) {
    if (snap == null || snap.isEmpty) return 'None';
    final parts = <String>[];
    if (snap['status'] != null) parts.add('Status: ${snap['status']}');
    if (snap['check_in_at'] != null) {
      final dt = DateTime.tryParse(snap['check_in_at'].toString());
      parts.add('In: ${dt != null ? formatLocalTime(dt) : snap['check_in_at']}');
    }
    if (snap['check_out_at'] != null) {
      final dt = DateTime.tryParse(snap['check_out_at'].toString());
      parts.add('Out: ${dt != null ? formatLocalTime(dt) : snap['check_out_at']}');
    }
    if (snap['short_leave'] == true) {
      parts.add('Short Leave');
    }
    return parts.isEmpty ? snap.toString() : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(staffAttendanceAuditProvider(attendanceId));

    return AlertDialog(
      title: Text('Audit Trail • $personName'),
      content: SizedBox(
        width: 540,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Date: $dateIso',
              style: const TextStyle(color: CampusStyle.muted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: auditAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Failed to load audit log: ${friendlyErrorMessage(e)}'),
                ),
                data: (events) {
                  if (events.isEmpty) {
                    return const Center(child: Text('No audit events recorded.'));
                  }
                  return ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final ev = events[i];
                      final whenStr = DateFormat('yyyy-MM-dd hh:mm a')
                          .format(ev.occurredAt.toLocal());
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F6FD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE4DDF3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${ev.eventType.toUpperCase()} (${ev.source})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CampusStyle.ink,
                                    fontSize: 12.5,
                                  ),
                                ),
                                Text(
                                  whenStr,
                                  style: const TextStyle(
                                    color: CampusStyle.muted,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                            if (ev.reason != null && ev.reason!.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Reason: ${ev.reason}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4C1D95),
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                            if (ev.oldValues != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Before: ${_formatSnapshot(ev.oldValues)}',
                                style: const TextStyle(
                                  color: CampusStyle.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (ev.newValues != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'After: ${_formatSnapshot(ev.newValues)}',
                                style: const TextStyle(
                                  color: CampusStyle.ink,
                                  fontSize: 12,
                                ),
                              ),
                            ] else if (ev.oldStatus != null || ev.newStatus != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${ev.oldStatus ?? '—'} → ${ev.newStatus ?? '—'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Opens Individual Person History + Summary dialog
/// (`GET /attendance/staff/{person_type}/{person_id}/history` + `/summary`).
Future<void> showStaffPersonHistoryDialog({
  required BuildContext context,
  required String personType,
  required String personId,
  required String personName,
  required DateTime dateFrom,
  required DateTime dateTo,
  bool isPrincipalReadOnly = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _StaffPersonHistoryDialog(
      personType: personType,
      personId: personId,
      personName: personName,
      initialDateFrom: dateFrom,
      initialDateTo: dateTo,
      isPrincipalReadOnly: isPrincipalReadOnly,
    ),
  );
}

class _StaffPersonHistoryDialog extends ConsumerStatefulWidget {
  final String personType;
  final String personId;
  final String personName;
  final DateTime initialDateFrom;
  final DateTime initialDateTo;
  final bool isPrincipalReadOnly;

  const _StaffPersonHistoryDialog({
    required this.personType,
    required this.personId,
    required this.personName,
    required this.initialDateFrom,
    required this.initialDateTo,
    required this.isPrincipalReadOnly,
  });

  @override
  ConsumerState<_StaffPersonHistoryDialog> createState() =>
      _StaffPersonHistoryDialogState();
}

class _StaffPersonHistoryDialogState
    extends ConsumerState<_StaffPersonHistoryDialog> {
  late DateTime _dateFrom;
  late DateTime _dateTo;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.initialDateFrom;
    _dateTo = widget.initialDateTo;
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _dateFrom, end: _dateTo),
    );
    if (range != null) {
      setState(() {
        _dateFrom = range.start;
        _dateTo = range.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromIso = formatApiDate(_dateFrom);
    final toIso = formatApiDate(_dateTo);
    final historyAsync = ref.watch(
      staffPersonHistoryProvider(
        StaffPersonHistoryFilter(
          personType: widget.personType,
          personId: widget.personId,
          dateFromIso: fromIso,
          dateToIso: toIso,
        ),
      ),
    );
    final summaryAsync = ref.watch(
      staffAttendanceSummaryProvider(
        StaffAttendanceSummaryFilter(
          dateFromIso: fromIso,
          dateToIso: toIso,
          personType: widget.personType,
          personId: widget.personId,
        ),
      ),
    );

    return AlertDialog(
      title: Text('${widget.personName} • History'),
      content: SizedBox(
        width: 620,
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${widget.personType == 'teacher' ? 'Teacher' : 'Non-Teaching Staff'} • $fromIso to $toIso',
                  style: const TextStyle(color: CampusStyle.muted, fontSize: 13),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _pickRange,
                  icon: const Icon(Icons.date_range_rounded, size: 16),
                  label: const Text('Range'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            summaryAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
              data: (summary) => Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MiniStat(
                    label: 'Attendance',
                    value: '${summary.attendancePercentage.toStringAsFixed(1)}%',
                  ),
                  _MiniStat(
                    label: 'Worked',
                    value: formatWorkedDuration(summary.totalWorkedMinutes),
                  ),
                  _MiniStat(label: 'Present', value: '${summary.present}'),
                  _MiniStat(label: 'Late', value: '${summary.late}'),
                  _MiniStat(label: 'Absent', value: '${summary.absent}'),
                  _MiniStat(label: 'Leave', value: '${summary.leave}'),
                  _MiniStat(label: 'Short Leave', value: '${summary.shortLeaveDays}'),
                  _MiniStat(
                    label: 'Open Out',
                    value: '${summary.incompleteCheckouts}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: historyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Failed to load history: ${friendlyErrorMessage(e)}'),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No attendance records in this date range.'),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final r = items[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE4DDF3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  r.date,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CampusStyle.ink,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StaffAttendanceStatusBadge(
                                    status: r.status,
                                    isMarked: r.isMarked,
                                    shortLeave: r.shortLeave,
                                    checkInSource: r.checkInSource,
                                    checkOutSource: r.checkOutSource,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Audit Log',
                                  onPressed: () => showStaffAttendanceAuditDialog(
                                    context: context,
                                    attendanceId: r.id,
                                    personName: widget.personName,
                                    dateIso: r.date,
                                  ),
                                  icon: const Icon(Icons.history_rounded, size: 19),
                                ),
                                if (!widget.isPrincipalReadOnly)
                                  IconButton(
                                    tooltip: 'Edit Record',
                                    onPressed: () => showEditStaffAttendanceDialog(
                                      context: context,
                                      attendanceId: r.id,
                                      personName: widget.personName,
                                      personType: widget.personType,
                                      dateIso: r.date,
                                      initialStatus: r.status,
                                      initialCheckIn: r.checkInAt,
                                      initialCheckOut: r.checkOutAt,
                                      initialShortLeave: r.shortLeave,
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 19),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'In: ${formatLocalTime(r.checkInAt)}  •  Out: ${formatLocalTime(r.checkOutAt)}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: CampusStyle.muted,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4C1D95),
        ),
      ),
    );
  }
}
