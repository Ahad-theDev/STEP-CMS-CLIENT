import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import 'package:cms/features/reports/application/reports_repository_provider.dart';
import 'package:cms/features/reports/data/models/daily_attendance_report_model.dart';
import 'package:cms/features/reports/services/report_pdf_service.dart';

class DailyAttendanceReportScreen extends ConsumerStatefulWidget {
  const DailyAttendanceReportScreen({super.key});

  @override
  ConsumerState<DailyAttendanceReportScreen> createState() =>
      _DailyAttendanceReportScreenState();
}

class _DailyAttendanceReportScreenState
    extends ConsumerState<DailyAttendanceReportScreen> {
  String? _selectedClassId;
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';

  Future<DailyAttendanceReport>? _reportFuture;
  DailyAttendanceReport? _loadedReport;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default to current month range
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  void _generateReport() {
    final repo = ref.read(reportsRepositoryProvider);
    final startDateStr = _selectedDateRange != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)
        : null;
    final endDateStr = _selectedDateRange != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)
        : null;

    setState(() {
      _reportFuture = repo.getDailyAttendanceReport(
        classId: _selectedClassId,
        dateFrom: startDateStr,
        dateTo: endDateStr,
      );
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  Future<void> _exportPdf() async {
    if (_loadedReport == null) return;
    setState(() => _isExporting = true);
    try {
      final scope = _selectedClassId != null
          ? 'Class Report (ID: $_selectedClassId)'
          : 'All Classes';
      final pdfBytes = await ReportPdfService.instance
          .generateDailyAttendancePdf(_loadedReport!, scopeDescription: scope);
      if (!mounted) return;
      await ReportPdfService.instance.previewOrPrintPdf(
        context,
        pdfBytes,
        title: 'Daily Attendance Report',
        fileName: 'daily_attendance_report.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(allClassesControllerProvider);

    return CampusPage(
      appBar: AppBar(
        title: const Text('Daily Attendance Report'),
        actions: [
          if (_loadedReport != null)
            IconButton(
              tooltip: 'Export PDF / Print',
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded),
              onPressed: _isExporting ? null : _exportPdf,
            ),
        ],
      ),
      body: CampusScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CampusSectionIntro(
              title: 'Daily Student Attendance',
              subtitle:
                  'Analyze morning and closing daily roll calls, working days, and attendance percentages across classes.',
            ),
            const SizedBox(height: 16),

            // Filter Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 650;
                        final classDropdown = classesAsync.when(
                          data: (classes) {
                            final activeClasses =
                                classes.where((c) => c.isActive).toList();
                            return DropdownButtonFormField<String?>(
                              initialValue: _selectedClassId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Select Class',
                                prefixIcon: Icon(Icons.class_rounded),
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All Classes'),
                                ),
                                ...activeClasses.map((c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text('${c.name} - ${c.section}'),
                                    )),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedClassId = val),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error loading classes: $e'),
                        );

                        final datePicker = InkWell(
                          onTap: _pickDateRange,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date Range',
                              prefixIcon: Icon(Icons.date_range_rounded),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedDateRange != null
                                  ? '${DateFormat('dd MMM').format(_selectedDateRange!.start)} – ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}'
                                  : 'Select Range',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );

                        if (isDesktop) {
                          return Row(
                            children: [
                              Expanded(child: classDropdown),
                              const SizedBox(width: 12),
                              Expanded(child: datePicker),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                                onPressed: _generateReport,
                                icon: const Icon(Icons.analytics_rounded),
                                label: const Text('Generate'),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              classDropdown,
                              const SizedBox(height: 12),
                              datePicker,
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _generateReport,
                                  icon: const Icon(Icons.analytics_rounded),
                                  label: const Text('Generate Report'),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Report Output
            if (_reportFuture != null)
              FutureBuilder<DailyAttendanceReport>(
                future: _reportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    final err = snapshot.error
                        .toString()
                        .replaceFirst('Exception: ', '');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                size: 48, color: Colors.red.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to generate report',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(err, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  }

                  final report = snapshot.data;
                  if (report == null) return const SizedBox.shrink();
                  _loadedReport = report;

                  final summary = report.summary;
                  final students = report.students;

                  // Filter students by search
                  final filteredStudents = students.where((s) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    return s.studentName.toLowerCase().contains(q) ||
                        s.rollNumber.toLowerCase().contains(q);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 700;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildKpiCard(
                                'Total Students',
                                '${students.length}',
                                Icons.people_alt_rounded,
                                CampusStyle.primary,
                                isWide,
                              ),
                              _buildKpiCard(
                                'Working Days',
                                '${summary.daysRecorded}',
                                Icons.calendar_today_rounded,
                                const Color(0xFF0288D1),
                                isWide,
                              ),
                              _buildKpiCard(
                                'Average Rate',
                                '${summary.attendancePercentage.toStringAsFixed(1)}%',
                                Icons.percent_rounded,
                                summary.attendancePercentage >= 75
                                    ? const Color(0xFF2E7D32)
                                    : Colors.red.shade700,
                                isWide,
                              ),
                              _buildKpiCard(
                                'Present Marks',
                                '${summary.present}',
                                Icons.check_circle_outline_rounded,
                                const Color(0xFF2E7D32),
                                isWide,
                              ),
                              _buildKpiCard(
                                'Absents',
                                '${summary.absent}',
                                Icons.cancel_outlined,
                                Colors.red.shade700,
                                isWide,
                              ),
                              _buildKpiCard(
                                'Leaves',
                                '${summary.leave}',
                                Icons.event_busy_rounded,
                                Colors.orange.shade800,
                                isWide,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Student Table Section Header & Search
                      Row(
                        children: [
                          Text(
                            'Student Breakdown (${filteredStudents.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: CampusStyle.ink,
                                ),
                          ),
                          const Spacer(),
                          FilledButton.tonalIcon(
                            onPressed: _isExporting ? null : _exportPdf,
                            icon: const Icon(Icons.picture_as_pdf_rounded,
                                size: 18),
                            label: const Text('Export PDF'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Search Box
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search student by name or roll number...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.trim()),
                      ),
                      const SizedBox(height: 12),

                      // DataTable Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 44,
                              dataRowMinHeight: 44,
                              dataRowMaxHeight: 52,
                              columns: const [
                                DataColumn(label: Text('Roll #')),
                                DataColumn(label: Text('Student Name')),
                                DataColumn(label: Text('Present')),
                                DataColumn(label: Text('Absent')),
                                DataColumn(label: Text('Late')),
                                DataColumn(label: Text('Leave')),
                                DataColumn(label: Text('Rate %')),
                              ],
                              rows: filteredStudents.map((st) {
                                final isGood = st.attendancePercentage >= 75.0;
                                return DataRow(
                                  cells: [
                                    DataCell(Text(st.rollNumber,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold))),
                                    DataCell(Text(st.studentName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600))),
                                    DataCell(Text('${st.presentDays}')),
                                    DataCell(Text('${st.absentDays}',
                                        style: TextStyle(
                                            color: st.absentDays > 0
                                                ? Colors.red.shade700
                                                : Colors.black))),
                                    DataCell(Text('${st.lateDays}')),
                                    DataCell(Text('${st.leaveDays}')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isGood
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${st.attendancePercentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isGood
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
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

  Widget _buildKpiCard(
      String label, String value, IconData icon, Color color, bool isWide) {
    return Container(
      width: isWide ? 150 : 105,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
