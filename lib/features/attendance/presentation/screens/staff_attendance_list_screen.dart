import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/staff_attendance_list_controller.dart';
import '../../data/models/staff_attendance.dart';
import '../../data/models/staff_attendance_unified_models.dart';
import '../widgets/staff_attendance_dialogs.dart';
import 'mark_staff_attendance_screen.dart';
import 'teacher_trends_screen.dart';

class StaffAttendanceListScreen extends ConsumerStatefulWidget {
  final bool isPrincipalReadOnly;
  final int initialTabIndex;

  const StaffAttendanceListScreen({
    super.key,
    this.isPrincipalReadOnly = false,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<StaffAttendanceListScreen> createState() =>
      _StaffAttendanceListScreenState();
}

class _StaffAttendanceListScreenState
    extends ConsumerState<StaffAttendanceListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // Records tab filters
  bool _useDateRange = false;
  DateTime _singleDate = DateTime.now();
  DateTime _rangeFrom = DateTime.now().subtract(const Duration(days: 6));
  DateTime _rangeTo = DateTime.now();
  String? _personTypeFilter; // null | 'teacher' | 'staff'
  String? _statusFilter; // null | 'present' | 'late' | 'absent' | 'leave'
  bool? _shortLeaveFilter; // null | true
  String _search = '';

  // Summary tab filters
  DateTime _summaryFrom = DateTime.now().subtract(const Duration(days: 29));
  DateTime _summaryTo = DateTime.now();
  String _summarySearch = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _pickSingleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _singleDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _singleDate = picked);
  }

  Future<void> _pickRecordsRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _rangeFrom, end: _rangeTo),
    );
    if (picked != null) {
      setState(() {
        _rangeFrom = picked.start;
        _rangeTo = picked.end;
      });
    }
  }

  Future<void> _pickSummaryRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _summaryFrom, end: _summaryTo),
    );
    if (picked != null) {
      setState(() {
        _summaryFrom = picked.start;
        _summaryTo = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = StaffAttendanceListFilter(
      dateIso: _useDateRange ? null : formatApiDate(_singleDate),
      dateFromIso: _useDateRange ? formatApiDate(_rangeFrom) : null,
      dateToIso: _useDateRange ? formatApiDate(_rangeTo) : null,
      personType: _personTypeFilter,
      status: _statusFilter,
      shortLeave: _shortLeaveFilter,
    );

    final summaryFilter = StaffAttendanceSummaryFilter(
      dateFromIso: formatApiDate(_summaryFrom),
      dateToIso: formatApiDate(_summaryTo),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff & Teacher Records'),
        backgroundColor: const Color(0xFFE4DDF3),
        actions: [
          IconButton(
            tooltip: 'Teacher Trends',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TeacherTrendsScreen()),
            ),
            icon: const Icon(Icons.trending_up_rounded),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MarkStaffAttendanceScreen(
                  isPrincipalReadOnly: widget.isPrincipalReadOnly,
                ),
              ),
            ),
            icon: const Icon(Icons.fact_check_outlined, size: 18),
            label: const Text('Daily Roster'),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt_rounded), text: 'Saved Records'),
            Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Summary & Hours'),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: CampusBackground()),
          SafeArea(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildRecordsTab(filter),
                _buildSummaryTab(summaryFilter),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsTab(StaffAttendanceListFilter filter) {
    final listAsync = ref.watch(staffAttendanceListProvider(filter));
    final compact = MediaQuery.sizeOf(context).width < 760;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(compact ? 14 : 20, 14, compact ? 14 : 20, 8),
          child: CampusCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Single Date')),
                        ButtonSegment(value: true, label: Text('Date Range')),
                      ],
                      selected: {_useDateRange},
                      onSelectionChanged: (s) =>
                          setState(() => _useDateRange = s.first),
                    ),
                    if (!_useDateRange)
                      OutlinedButton.icon(
                        onPressed: _pickSingleDate,
                        icon: const Icon(Icons.calendar_today_rounded, size: 17),
                        label: Text(formatApiDate(_singleDate)),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _pickRecordsRange,
                        icon: const Icon(Icons.date_range_rounded, size: 17),
                        label: Text(
                          '${formatApiDate(_rangeFrom)} → ${formatApiDate(_rangeTo)}',
                        ),
                      ),
                    SizedBox(
                      width: 210,
                      child: TextField(
                        onChanged: (v) => setState(() => _search = v),
                        decoration: const InputDecoration(
                          hintText: 'Search name...',
                          prefixIcon: Icon(Icons.search_rounded, size: 19),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: () =>
                          ref.invalidate(staffAttendanceListProvider(filter)),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    DropdownButton<String?>(
                      value: _personTypeFilter,
                      hint: const Text('Role: All'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Role: All')),
                        DropdownMenuItem(
                            value: 'teacher', child: Text('Teachers Only')),
                        DropdownMenuItem(
                            value: 'staff', child: Text('Non-Teaching Staff')),
                      ],
                      onChanged: (v) => setState(() => _personTypeFilter = v),
                    ),
                    DropdownButton<String?>(
                      value: _statusFilter,
                      hint: const Text('Status: All'),
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('Status: All')),
                        DropdownMenuItem(
                            value: 'present', child: Text('Present')),
                        DropdownMenuItem(value: 'late', child: Text('Late')),
                        DropdownMenuItem(
                            value: 'absent', child: Text('Absent')),
                        DropdownMenuItem(value: 'leave', child: Text('Leave')),
                      ],
                      onChanged: (v) => setState(() => _statusFilter = v),
                    ),
                    FilterChip(
                      label: const Text('Short Leave Only'),
                      selected: _shortLeaveFilter == true,
                      onSelected: (v) =>
                          setState(() => _shortLeaveFilter = v ? true : null),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load records: ${friendlyErrorMessage(e)}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(staffAttendanceListProvider(filter)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (items) {
              final q = _search.trim().toLowerCase();
              final filtered = q.isEmpty
                  ? items
                  : items
                      .where(
                        (r) =>
                            r.displayName.toLowerCase().contains(q) ||
                            (r.designation ?? '').toLowerCase().contains(q),
                      )
                      .toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No saved attendance records match your filters.',
                    style: TextStyle(color: CampusStyle.muted),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(staffAttendanceListProvider(filter)),
                child: compact
                    ? ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _buildRecordCard(filtered[i]),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                        child: CampusCard(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Role')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Check-In')),
                                DataColumn(label: Text('Check-Out')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filtered
                                  .map((r) => _buildDataRow(r))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(StaffAttendance r) {
    final roleText = r.effectivePersonType == 'teacher'
        ? 'Teacher'
        : (r.designation?.isNotEmpty == true ? r.designation! : 'Staff');
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE4DDF3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: CampusStyle.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$roleText  •  ${r.date}',
                        style: const TextStyle(
                          color: CampusStyle.muted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRowActions(r),
              ],
            ),
            const SizedBox(height: 8),
            StaffAttendanceStatusBadge(
              status: r.status,
              isMarked: r.isMarked,
              shortLeave: r.shortLeave,
              checkInSource: r.checkInSource,
              checkOutSource: r.checkOutSource,
            ),
            const SizedBox(height: 8),
            Text(
              'Check-In: ${formatLocalTime(r.checkInAt)}   •   Check-Out: ${formatLocalTime(r.checkOutAt)}',
              style: const TextStyle(
                color: CampusStyle.ink,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(StaffAttendance r) {
    final roleText = r.effectivePersonType == 'teacher'
        ? 'Teacher'
        : (r.designation?.isNotEmpty == true ? r.designation! : 'Staff');
    return DataRow(
      cells: [
        DataCell(
          Text(
            r.displayName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        DataCell(Text(roleText)),
        DataCell(Text(r.date)),
        DataCell(
          StaffAttendanceStatusBadge(
            status: r.status,
            isMarked: r.isMarked,
            shortLeave: r.shortLeave,
            checkInSource: r.checkInSource,
            checkOutSource: r.checkOutSource,
          ),
        ),
        DataCell(Text(formatLocalTime(r.checkInAt))),
        DataCell(Text(formatLocalTime(r.checkOutAt))),
        DataCell(_buildRowActions(r)),
      ],
    );
  }

  Widget _buildRowActions(StaffAttendance r) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Person History',
          onPressed: () {
            final now = DateTime.now();
            showStaffPersonHistoryDialog(
              context: context,
              personType: r.effectivePersonType,
              personId: r.effectivePersonId,
              personName: r.displayName,
              dateFrom: now.subtract(const Duration(days: 30)),
              dateTo: now,
              isPrincipalReadOnly: widget.isPrincipalReadOnly,
            );
          },
          icon: const Icon(Icons.person_search_outlined, size: 20),
        ),
        IconButton(
          tooltip: 'Audit Trail',
          onPressed: () => showStaffAttendanceAuditDialog(
            context: context,
            attendanceId: r.id,
            personName: r.displayName,
            dateIso: r.date,
          ),
          icon: const Icon(Icons.history_rounded, size: 20),
        ),
        if (!widget.isPrincipalReadOnly)
          IconButton(
            tooltip: 'Edit with Reason',
            onPressed: () async {
              final updated = await showEditStaffAttendanceDialog(
                context: context,
                attendanceId: r.id,
                personName: r.displayName,
                personType: r.effectivePersonType,
                dateIso: r.date,
                initialStatus: r.status,
                initialCheckIn: r.checkInAt,
                initialCheckOut: r.checkOutAt,
                initialShortLeave: r.shortLeave,
              );
              if (updated != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Updated ${r.displayName} (${updated.status}).',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
      ],
    );
  }

  Widget _buildSummaryTab(StaffAttendanceSummaryFilter summaryFilter) {
    final summaryAsync =
        ref.watch(staffAttendanceSummaryProvider(summaryFilter));
    final compact = MediaQuery.sizeOf(context).width < 760;

    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(staffAttendanceSummaryProvider(summaryFilter)),
      child: ListView(
        padding: EdgeInsets.all(compact ? 14 : 20),
        children: [
          CampusCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickSummaryRange,
                  icon: const Icon(Icons.date_range_rounded, size: 18),
                  label: Text(
                    '${formatApiDate(_summaryFrom)} → ${formatApiDate(_summaryTo)}',
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: TextField(
                    onChanged: (v) => setState(() => _summarySearch = v),
                    decoration: const InputDecoration(
                      hintText: 'Filter person summary...',
                      prefixIcon: Icon(Icons.search_rounded, size: 19),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh Summary',
                  onPressed: () => ref.invalidate(
                    staffAttendanceSummaryProvider(summaryFilter),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          summaryAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => CampusCard(
              child: Text('Failed to load summary: ${friendlyErrorMessage(e)}'),
            ),
            data: (summary) {
              final q = _summarySearch.trim().toLowerCase();
              final people = q.isEmpty
                  ? summary.people
                  : summary.people
                      .where(
                        (p) =>
                            p.personName.toLowerCase().contains(q) ||
                            p.personType.toLowerCase().contains(q),
                      )
                      .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _SummaryKpiTile(
                        label: 'Attendance %',
                        value:
                            '${summary.attendancePercentage.toStringAsFixed(1)}%',
                        color: CampusStyle.primary,
                      ),
                      _SummaryKpiTile(
                        label: 'Total Worked',
                        value:
                            formatWorkedDuration(summary.totalWorkedMinutes),
                        color: const Color(0xFF0369A1),
                      ),
                      _SummaryKpiTile(
                        label: 'Present',
                        value: '${summary.present}',
                        color: const Color(0xFF15803D),
                      ),
                      _SummaryKpiTile(
                        label: 'Late',
                        value: '${summary.late}',
                        color: const Color(0xFFB45309),
                      ),
                      _SummaryKpiTile(
                        label: 'Absent',
                        value: '${summary.absent}',
                        color: const Color(0xFFB91C1C),
                      ),
                      _SummaryKpiTile(
                        label: 'Leave',
                        value: '${summary.leave}',
                        color: const Color(0xFF5B21B6),
                      ),
                      _SummaryKpiTile(
                        label: 'Short Leave',
                        value: '${summary.shortLeaveDays}',
                        color: const Color(0xFFD97706),
                      ),
                      _SummaryKpiTile(
                        label: 'Open Checkouts',
                        value: '${summary.incompleteCheckouts}',
                        color: const Color(0xFF475569),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculated across ${summary.totalRecords} saved record(s) for ${summary.peopleWithRecords} person(s). Unmarked days are excluded.',
                    style: const TextStyle(
                      color: CampusStyle.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (people.isEmpty)
                    const CampusCard(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text('No summary records for selected filters.'),
                        ),
                      ),
                    )
                  else
                    ...people.map(
                      (p) => _buildPersonSummaryCard(p),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonSummaryCard(StaffPersonSummary p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE4DDF3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                p.personName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: CampusStyle.ink,
                ),
              ),
            ),
            Text(
              '${p.attendancePercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: CampusStyle.primary,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${p.personType == 'teacher' ? 'Teacher' : 'Staff'} • '
            'Worked ${formatWorkedDuration(p.totalWorkedMinutes)} • '
            'P:${p.present} L:${p.late} A:${p.absent} Lv:${p.leave} SL:${p.shortLeaveDays}'
            '${p.incompleteCheckouts > 0 ? ' • Open Out:${p.incompleteCheckouts}' : ''}',
            style: const TextStyle(fontSize: 12.5, color: CampusStyle.muted),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => showStaffPersonHistoryDialog(
          context: context,
          personType: p.personType,
          personId: p.personId,
          personName: p.personName,
          dateFrom: _summaryFrom,
          dateTo: _summaryTo,
          isPrincipalReadOnly: widget.isPrincipalReadOnly,
        ),
      ),
    );
  }
}

class _SummaryKpiTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryKpiTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CampusStyle.muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}