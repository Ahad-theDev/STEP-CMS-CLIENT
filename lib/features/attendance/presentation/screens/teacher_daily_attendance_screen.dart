import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/teacher_biometric_attendance_providers.dart';
import '../../data/models/teacher_attendance_models.dart';
import '../widgets/teacher_attendance_badges.dart';
import 'teacher_trends_screen.dart';

class TeacherDailyAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherDailyAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherDailyAttendanceScreen> createState() =>
      _TeacherDailyAttendanceScreenState();
}

class _TeacherDailyAttendanceScreenState
    extends ConsumerState<TeacherDailyAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTimeRange _summaryRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  // Manual Timestamp Event form state (Screen E)
  Teacher? _manualTeacher;
  String _manualEventType = 'check_in';
  bool _submittingManual = false;
  TeacherManualEventRequest? _pendingRetryManual;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickSummaryRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _summaryRange,
    );
    if (picked != null && mounted) {
      setState(() => _summaryRange = picked);
    }
  }

  bool _isRetryable(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;
        case DioExceptionType.badResponse:
          return (e.response?.statusCode ?? 0) >= 500;
        default:
          return false;
      }
    }
    return false;
  }

  Future<void> _submitManualEvent({TeacherManualEventRequest? retryReq}) async {
    if (retryReq == null && _manualTeacher == null) return;
    final req = retryReq ??
        TeacherManualEventRequest(
          eventId: generateEventUuid(),
          teacherId: _manualTeacher!.id,
          eventType: _manualEventType,
        );

    setState(() => _submittingManual = true);
    try {
      final resp = await ref
          .read(teacherBiometricAttendanceRepositoryProvider)
          .submitManualEvent(req);
      ref.invalidate(
        teacherDailyAttendanceProvider(formatApiDate(_selectedDate)),
      );
      ref.invalidate(
        teacherAttendanceSummaryProvider(
          TeacherSummaryRange(
            dateFromIso: formatApiDate(_summaryRange.start),
            dateToIso: formatApiDate(_summaryRange.end),
          ),
        ),
      );
      if (!mounted) return;
      setState(() {
        _submittingManual = false;
        _pendingRetryManual = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${resp.teacherName}: ${resp.message} (${resp.attendanceStatus.toUpperCase()})',
          ),
          backgroundColor: resp.duplicate
              ? const Color(0xFF2563EB)
              : const Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final retryable = _isRetryable(e);
      setState(() {
        _submittingManual = false;
        _pendingRetryManual = retryable ? req : null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyErrorMessage(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: CampusPage(
        appBar: AppBar(
          title: const Text('Teacher Check-In / Out'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.access_time_filled_rounded),
                text: 'Daily Check-In / Out',
              ),
              Tab(
                icon: Icon(Icons.analytics_outlined),
                text: 'Period Summary',
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Teacher Trends & Charts',
              icon: const Icon(Icons.pie_chart_outline_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeacherTrendsScreen()),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDailyTab(),
            _buildSummaryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTab() {
    final dateIso = formatApiDate(_selectedDate);
    final dailyAsync = ref.watch(teacherDailyAttendanceProvider(dateIso));
    final teachersAsync = ref.watch(teachersListControllerProvider);

    return CampusScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CampusSectionIntro(
            title: 'Teacher Daily Check-In & Check-Out',
            subtitle:
                'Record timestamped manual arrival/departure events (bypassing fingerprint cutoff) and review daily check-in, check-out, short leave, and event sources.',
          ),
          const SizedBox(height: 16),
          _buildManualEventPanel(teachersAsync),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Viewing Records Date',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                      isDense: true,
                    ),
                    child: Text(
                      dateIso,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Refresh Daily Records',
                onPressed: () =>
                    ref.invalidate(teacherDailyAttendanceProvider(dateIso)),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 16),
          dailyAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                friendlyErrorMessage(e),
                style: const TextStyle(color: Colors.red),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F8FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E2F0)),
                  ),
                  child: Text(
                    'No teacher attendance records found for $dateIso.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: CampusStyle.muted),
                  ),
                );
              }
              return _buildDailyRecordsList(items);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManualEventPanel(AsyncValue<List<Teacher>> teachersAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9D2F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.edit_calendar_rounded, color: CampusStyle.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quick Manual Timestamp Check-In / Check-Out (Today)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Uses current server time, applies weekday late/short-leave policy, and bypasses fingerprint cutoff.',
            style: TextStyle(fontSize: 12, color: CampusStyle.muted),
          ),
          const SizedBox(height: 12),
          teachersAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text(
              friendlyErrorMessage(e),
              style: const TextStyle(color: Colors.red),
            ),
            data: (teachers) {
              final active = teachers.where((t) => t.isActive).toList()
                ..sort((a, b) => a.fullName.compareTo(b.fullName));
              return LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 700;
                  final teacherDropdown = DropdownButtonFormField<Teacher>(
                    initialValue: active.contains(_manualTeacher)
                        ? _manualTeacher
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Teacher',
                      isDense: true,
                    ),
                    items: active
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t.fullName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _manualTeacher = v;
                      _pendingRetryManual = null;
                    }),
                  );

                  final modeChips = Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Check-In'),
                        selected: _manualEventType == 'check_in',
                        onSelected: (_) => setState(() {
                          _manualEventType = 'check_in';
                          _pendingRetryManual = null;
                        }),
                      ),
                      ChoiceChip(
                        label: const Text('Check-Out'),
                        selected: _manualEventType == 'check_out',
                        onSelected: (_) => setState(() {
                          _manualEventType = 'check_out';
                          _pendingRetryManual = null;
                        }),
                      ),
                    ],
                  );

                  final submitBtn = FilledButton.icon(
                    onPressed: (_submittingManual || _manualTeacher == null)
                        ? null
                        : () => _submitManualEvent(),
                    icon: _submittingManual
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _submittingManual ? 'Submitting...' : 'Record Event',
                    ),
                  );

                  if (wide) {
                    return Row(
                      children: [
                        Expanded(flex: 3, child: teacherDropdown),
                        const SizedBox(width: 12),
                        modeChips,
                        const SizedBox(width: 12),
                        submitBtn,
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      teacherDropdown,
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [modeChips, submitBtn],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          if (_pendingRetryManual != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _submittingManual
                    ? null
                    : () => _submitManualEvent(retryReq: _pendingRetryManual),
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Retry Pending Event (Same ID)'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyRecordsList(List<TeacherDailyAttendanceItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: items.map((r) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE3E1EE)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            r.teacherName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          AttendanceStatusBadge(status: r.status),
                          if (r.shortLeave) const ShortLeaveBadge(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 18,
                        runSpacing: 8,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check-In',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: CampusStyle.muted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    formatLocalTime(r.checkInAt),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  AttendanceSourceChip(source: r.checkInSource),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check-Out',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: CampusStyle.muted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    formatLocalTime(r.checkOutAt),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  AttendanceSourceChip(source: r.checkOutSource),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Teacher')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Check-In')),
              DataColumn(label: Text('In Source')),
              DataColumn(label: Text('Check-Out')),
              DataColumn(label: Text('Out Source')),
              DataColumn(label: Text('Short Leave')),
            ],
            rows: items.map((r) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      r.teacherName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(AttendanceStatusBadge(status: r.status)),
                  DataCell(Text(formatLocalTime(r.checkInAt))),
                  DataCell(AttendanceSourceChip(source: r.checkInSource)),
                  DataCell(Text(formatLocalTime(r.checkOutAt))),
                  DataCell(AttendanceSourceChip(source: r.checkOutSource)),
                  DataCell(
                    r.shortLeave
                        ? const ShortLeaveBadge()
                        : const Text('—', style: TextStyle(color: CampusStyle.muted)),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab() {
    final rangeKey = TeacherSummaryRange(
      dateFromIso: formatApiDate(_summaryRange.start),
      dateToIso: formatApiDate(_summaryRange.end),
    );
    final summaryAsync = ref.watch(teacherAttendanceSummaryProvider(rangeKey));

    return CampusScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CampusSectionIntro(
            title: 'Teacher Attendance Period Summary',
            subtitle:
                'Aggregated teacher check-in records across an inclusive date range including short leaves and status totals.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _pickSummaryRange,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date Range (Inclusive)',
                      prefixIcon: Icon(Icons.date_range_rounded),
                      isDense: true,
                    ),
                    child: Text(
                      '${rangeKey.dateFromIso} to ${rangeKey.dateToIso}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Refresh Summary',
                onPressed: () =>
                    ref.invalidate(teacherAttendanceSummaryProvider(rangeKey)),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 20),
          summaryAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text(
              friendlyErrorMessage(e),
              style: const TextStyle(color: Colors.red),
            ),
            data: (s) {
              final kpis = [
                _KpiSpec('Total Records', s.totalRecords, CampusStyle.primary, Icons.fact_check_outlined),
                _KpiSpec('Present', s.present, const Color(0xFF16A34A), Icons.check_circle_outline),
                _KpiSpec('Late', s.late, const Color(0xFFD97706), Icons.schedule_rounded),
                _KpiSpec('Short Leave', s.shortLeave, const Color(0xFFB45309), Icons.timer_off_outlined),
                _KpiSpec('Absent', s.absent, const Color(0xFFDC2626), Icons.cancel_outlined),
                _KpiSpec('On Leave', s.leave, const Color(0xFF2563EB), Icons.event_busy_outlined),
              ];
              return LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth >= 750
                      ? 3
                      : constraints.maxWidth >= 460
                          ? 2
                          : 1;
                  final cardWidth =
                      (constraints.maxWidth - (cols - 1) * 12) / cols;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: kpis
                        .map(
                          (k) => SizedBox(
                            width: cardWidth,
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE3E1EE),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        k.color.withValues(alpha: 0.12),
                                    child: Icon(k.icon, color: k.color),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${k.value}',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: k.color,
                                        ),
                                      ),
                                      Text(
                                        k.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: CampusStyle.muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KpiSpec {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _KpiSpec(this.label, this.value, this.color, this.icon);
}
