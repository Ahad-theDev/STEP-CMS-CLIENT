import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/reports/application/reports_repository_provider.dart';
import 'package:cms/features/reports/data/models/marks_report_model.dart';
import 'package:cms/features/reports/services/report_pdf_service.dart';

class MarksReportScreen extends ConsumerStatefulWidget {
  const MarksReportScreen({super.key, this.initialExamId});

  final String? initialExamId;

  @override
  ConsumerState<MarksReportScreen> createState() => _MarksReportScreenState();
}

class _MarksReportScreenState extends ConsumerState<MarksReportScreen> {
  String? _selectedExamId;
  String _searchQuery = '';

  Future<ExamListResponse>? _examsFuture;
  Future<MarksReport>? _reportFuture;
  MarksReport? _loadedReport;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _selectedExamId = widget.initialExamId;
    _loadExams();
    if (_selectedExamId != null) {
      _generateReport();
    }
  }

  void _loadExams() {
    final repo = ref.read(examRepositoryProvider);
    setState(() {
      _examsFuture = repo.listExams(page: 1, limit: 100);
    });
  }

  void _generateReport() {
    if (_selectedExamId == null) return;
    final repo = ref.read(reportsRepositoryProvider);
    setState(() {
      _reportFuture = repo.getMarksReport(examId: _selectedExamId!);
    });
  }

  Future<void> _exportPdf() async {
    if (_loadedReport == null) return;
    setState(() => _isExporting = true);
    try {
      final scope = '${_loadedReport!.exam.title} (${_loadedReport!.exam.academicYear})';
      final pdfBytes = await ReportPdfService.instance
          .generateMarksPdf(_loadedReport!, scopeDescription: scope);
      if (!mounted) return;
      await ReportPdfService.instance.previewOrPrintPdf(
        context,
        pdfBytes,
        title: 'Marks & Merit Report',
        fileName: 'marks_and_merit_report.pdf',
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

  Future<void> _exportStudentReportCard(MarksReportStudent st) async {
    if (_loadedReport == null) return;
    try {
      final studentResult = st.toStudentExamResult(
        examId: _loadedReport!.exam.examId,
        examTitle: _loadedReport!.exam.title,
      );
      final pdfBytes = await ReportPdfService.instance
          .generateStudentReportCardPdf(
        studentResult,
        academicYear: _loadedReport!.exam.academicYear,
      );
      if (!mounted) return;
      await ReportPdfService.instance.previewOrPrintPdf(
        context,
        pdfBytes,
        title: '${st.studentName} - Report Card',
        fileName: '${st.studentName}_Report_Card.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export Report Card: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampusPage(
      appBar: AppBar(
        title: const Text('Exam Marks & Merit Report'),
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
              title: 'Academic Performance & Results',
              subtitle:
                  'View comprehensive student rankings, subject score statistics, and export official printable merit lists.',
            ),
            const SizedBox(height: 16),

            // Exam Selection Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<ExamListResponse>(
                  future: _examsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }

                    final exams = snapshot.data?.items ?? [];
                    final publishedExams = exams
                        .where((e) => e.status == ExamStatus.published)
                        .toList();

                    return Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth >= 650;
                            final examDropdown =
                                DropdownButtonFormField<String>(
                              initialValue: _selectedExamId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Select Published Examination *',
                                prefixIcon:
                                    Icon(Icons.assignment_turned_in_rounded),
                                border: OutlineInputBorder(),
                              ),
                              items: (publishedExams.isNotEmpty
                                      ? publishedExams
                                      : exams)
                                  .map((e) {
                                final isPub = e.status == ExamStatus.published;
                                return DropdownMenuItem(
                                  value: e.id,
                                  child: Text(
                                    '${e.title} (${e.academicYear}) ${isPub ? "✓" : "[Draft]"}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _selectedExamId = val);
                                _generateReport();
                              },
                            );

                            if (isDesktop) {
                              return Row(
                                children: [
                                  Expanded(child: examDropdown),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 16),
                                    ),
                                    onPressed: _selectedExamId != null
                                        ? _generateReport
                                        : null,
                                    icon: const Icon(Icons.analytics_rounded),
                                    label: const Text('View Report'),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  examDropdown,
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: _selectedExamId != null
                                          ? _generateReport
                                          : null,
                                      icon: const Icon(Icons.analytics_rounded),
                                      label: const Text('View Report'),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Report Output
            if (_reportFuture != null)
              FutureBuilder<MarksReport>(
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
                              'Failed to load examination report',
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

                  final filteredStudents = students.where((s) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    return s.studentName.toLowerCase().contains(q) ||
                        s.rollNumber.toLowerCase().contains(q);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 700;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildKpiCard(
                                'Candidates',
                                '${summary.studentsCount}',
                                Icons.people_alt_rounded,
                                CampusStyle.primary,
                                isWide,
                              ),
                              _buildKpiCard(
                                'Class Average',
                                '${summary.averagePercentage.toStringAsFixed(1)}%',
                                Icons.functions_rounded,
                                const Color(0xFF0288D1),
                                isWide,
                              ),
                              _buildKpiCard(
                                'Marks Obtained',
                                summary.totalObtainedMarks.toStringAsFixed(1),
                                Icons.emoji_events_rounded,
                                const Color(0xFF2E7D32),
                                isWide,
                              ),
                              _buildKpiCard(
                                'Total Maximum',
                                summary.totalMaximumMarks.toStringAsFixed(0),
                                Icons.score_rounded,
                                CampusStyle.primary,
                                isWide,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Subject Performance Statistics
                      if (report.subjects.isNotEmpty) ...[
                        Text(
                          'Subject Statistics (${report.subjects.length})',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: CampusStyle.ink,
                                  ),
                        ),
                        const SizedBox(height: 8),
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
                                headingRowHeight: 40,
                                dataRowMinHeight: 40,
                                dataRowMaxHeight: 46,
                                columns: const [
                                  DataColumn(label: Text('Subject')),
                                  DataColumn(label: Text('Max Per Student')),
                                  DataColumn(label: Text('Class Max')),
                                  DataColumn(label: Text('Class Obtained')),
                                  DataColumn(label: Text('Candidates Marked')),
                                ],
                                rows: report.subjects.map((sub) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(sub.subjectName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600))),
                                      DataCell(Text(
                                          sub.maxMarksPerStudent.toStringAsFixed(0))),
                                      DataCell(Text(
                                          sub.classMaximumMarks.toStringAsFixed(0))),
                                      DataCell(Text(
                                          sub.classObtainedMarks.toStringAsFixed(1))),
                                      DataCell(Text('${sub.studentsMarked}')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Merit List Roster
                      Row(
                        children: [
                          Text(
                            'Student Merit Roster (${filteredStudents.length})',
                            style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                DataColumn(label: Text('Marks Obtained')),
                                DataColumn(label: Text('Maximum')),
                                DataColumn(label: Text('Percentage')),
                                DataColumn(label: Text('Result')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows: filteredStudents.map((st) {
                                final isPassed = st.percentage >= 33.0;
                                return DataRow(
                                  cells: [
                                    DataCell(Text(st.rollNumber,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold))),
                                    DataCell(Text(st.studentName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600))),
                                    DataCell(Text(
                                      st.totalObtained.toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                    DataCell(Text(
                                        st.totalMaximum.toStringAsFixed(0))),
                                    DataCell(Text(
                                        '${st.percentage.toStringAsFixed(1)}%')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isPassed
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isPassed ? 'PASS' : 'FAIL',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: isPassed
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(
                                          Icons.picture_as_pdf_rounded,
                                          size: 18,
                                          color: CampusStyle.primary,
                                        ),
                                        tooltip: 'Report Card PDF',
                                        onPressed: () =>
                                            _exportStudentReportCard(st),
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
      width: isWide ? 170 : 110,
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
