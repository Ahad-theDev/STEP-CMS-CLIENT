import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/teacher_biometric_attendance_providers.dart';
import '../../data/models/teacher_attendance_models.dart';

class AttendancePolicyScreen extends ConsumerStatefulWidget {
  const AttendancePolicyScreen({super.key});

  @override
  ConsumerState<AttendancePolicyScreen> createState() =>
      _AttendancePolicyScreenState();
}

class _AttendancePolicyScreenState
    extends ConsumerState<AttendancePolicyScreen> {
  List<AttendancePolicyDay>? _draftDays;
  bool _isSaving = false;

  void _initDraftIfNeeded(List<AttendancePolicyDay> serverRows) {
    if (_draftDays != null) return;
    final byDay = {for (final r in serverRows) r.weekday: r};
    _draftDays = List.generate(7, (weekday) {
      return byDay[weekday] ??
          AttendancePolicyDay.defaultForDay(
            weekday,
          ).copyWith(isActive: serverRows.isEmpty ? weekday < 6 : false);
    });
  }

  Future<void> _pickTime(int index, String field) async {
    final day = _draftDays![index];
    final currentStr = field == 'start'
        ? day.startTime
        : field == 'end'
            ? day.endTime
            : day.checkInCutoff;
    final picked = await showTimePicker(
      context: context,
      initialTime: parseApiTimeOfDay(currentStr),
    );
    if (picked == null) return;
    final formatted = formatTimeOfDayForApi(picked);
    setState(() {
      _draftDays![index] = day.copyWith(
        startTime: field == 'start' ? formatted : null,
        endTime: field == 'end' ? formatted : null,
        checkInCutoff: field == 'cutoff' ? formatted : null,
      );
    });
  }

  void _applyMondayPresetToActiveWeekdays({required bool includeSaturday}) {
    if (_draftDays == null || _draftDays!.isEmpty) return;
    final mon = _draftDays![0];
    setState(() {
      for (int i = 0; i < 7; i++) {
        final shouldEnable = includeSaturday ? i < 6 : i < 5;
        _draftDays![i] = _draftDays![i].copyWith(
          startTime: mon.startTime,
          endTime: mon.endTime,
          checkInCutoff: mon.checkInCutoff,
          lateGraceMinutes: mon.lateGraceMinutes,
          earlyLeaveGraceMinutes: mon.earlyLeaveGraceMinutes,
          isActive: shouldEnable,
        );
      }
    });
  }

  Future<void> _savePolicy() async {
    final days = _draftDays;
    if (days == null) return;

    for (final d in days) {
      final err = d.validate();
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.red.shade700),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final saved = await ref
          .read(teacherBiometricAttendanceRepositoryProvider)
          .updatePolicy(days);
      ref.invalidate(attendancePolicyProvider);
      if (!mounted) return;
      final byDay = {for (final r in saved) r.weekday: r};
      setState(() {
        _draftDays = List.generate(
          7,
          (w) => byDay[w] ?? days[w].copyWith(isActive: false),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weekly teacher attendance policy saved.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyErrorMessage(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final policyAsync = ref.watch(attendancePolicyProvider);

    return CampusPage(
      appBar: AppBar(
        title: const Text('Teacher Attendance Policy'),
        actions: [
          IconButton(
            tooltip: 'Reload from Server',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _draftDays = null);
              ref.invalidate(attendancePolicyProvider);
            },
          ),
        ],
      ),
      body: CampusScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CampusSectionIntro(
              title: 'Weekly School Schedule & Grace Rules',
              subtitle:
                  'Configure arrival time, departure time, late grace, early-leave grace (short leave), and fingerprint check-in cutoff for Monday through Sunday.',
            ),
            const SizedBox(height: 16),
            policyAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Column(
                children: [
                  Text(
                    friendlyErrorMessage(e),
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(attendancePolicyProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              data: (serverRows) {
                _initDraftIfNeeded(serverRows);
                final days = _draftDays!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _applyMondayPresetToActiveWeekdays(
                                includeSaturday: true,
                              ),
                              icon: const Icon(Icons.copy_all_rounded, size: 18),
                              label: const Text('Copy Mon to Mon–Sat'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _applyMondayPresetToActiveWeekdays(
                                includeSaturday: false,
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Copy Mon to Mon–Fri'),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _savePolicy,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(_isSaving ? 'Saving...' : 'Save Weekly Policy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(days.length, (i) => _buildDayCard(i, days[i])),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _savePolicy,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save Complete Weekly Policy',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(int index, AttendancePolicyDay day) {
    final validationError = day.validate();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: validationError != null
              ? Colors.red.shade400
              : day.isActive
                  ? const Color(0xFFD9D4F0)
                  : const Color(0xFFEAE8F2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    day.weekdayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: day.isActive ? CampusStyle.ink : CampusStyle.muted,
                    ),
                  ),
                ),
                Text(
                  day.isActive ? 'Working Day' : 'Off / Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: day.isActive
                        ? const Color(0xFF16A34A)
                        : CampusStyle.muted,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: day.isActive,
                  onChanged: (v) => setState(
                    () => _draftDays![index] = day.copyWith(isActive: v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 620;
                final timePickers = [
                  _TimeTile(
                    label: 'Start Time',
                    valueText:
                        formatTimeOfDay12h(parseApiTimeOfDay(day.startTime)),
                    onTap: () => _pickTime(index, 'start'),
                  ),
                  _TimeTile(
                    label: 'End Time',
                    valueText:
                        formatTimeOfDay12h(parseApiTimeOfDay(day.endTime)),
                    onTap: () => _pickTime(index, 'end'),
                  ),
                  _TimeTile(
                    label: 'Check-In Cutoff',
                    valueText: formatTimeOfDay12h(
                      parseApiTimeOfDay(day.checkInCutoff),
                    ),
                    onTap: () => _pickTime(index, 'cutoff'),
                  ),
                ];

                final graceInputs = [
                  _GraceStepper(
                    label: 'Late Grace (min)',
                    value: day.lateGraceMinutes,
                    onChanged: (v) => setState(
                      () => _draftDays![index] = day.copyWith(
                        lateGraceMinutes: v,
                      ),
                    ),
                  ),
                  _GraceStepper(
                    label: 'Early Leave Grace (min)',
                    value: day.earlyLeaveGraceMinutes,
                    onChanged: (v) => setState(
                      () => _draftDays![index] = day.copyWith(
                        earlyLeaveGraceMinutes: v,
                      ),
                    ),
                  ),
                ];

                if (narrow) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: timePickers[0]),
                          const SizedBox(width: 8),
                          Expanded(child: timePickers[1]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      timePickers[2],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: graceInputs[0]),
                          const SizedBox(width: 8),
                          Expanded(child: graceInputs[1]),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: timePickers[0]),
                    const SizedBox(width: 8),
                    Expanded(child: timePickers[1]),
                    const SizedBox(width: 8),
                    Expanded(child: timePickers[2]),
                    const SizedBox(width: 8),
                    Expanded(child: graceInputs[0]),
                    const SizedBox(width: 8),
                    Expanded(child: graceInputs[1]),
                  ],
                );
              },
            ),
            if (validationError != null) ...[
              const SizedBox(height: 8),
              Text(
                validationError,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.valueText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          suffixIcon: const Icon(Icons.access_time_rounded, size: 18),
        ),
        child: Text(
          valueText,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _GraceStepper extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _GraceStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: value > 0 ? () => onChanged((value - 5).clamp(0, 240)) : null,
            child: Icon(
              Icons.remove_circle_outline,
              size: 20,
              color: value > 0 ? CampusStyle.primary : Colors.grey.shade400,
            ),
          ),
          Text(
            '$value m',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          InkWell(
            onTap:
                value < 240 ? () => onChanged((value + 5).clamp(0, 240)) : null,
            child: Icon(
              Icons.add_circle_outline,
              size: 20,
              color: value < 240 ? CampusStyle.primary : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
