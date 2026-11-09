import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/models/exam_results_model.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/reports/services/report_pdf_service.dart';

class StudentExamHistoryScreen extends ConsumerStatefulWidget {
  const StudentExamHistoryScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    this.rollNumber,
    this.className,
  });

  final String studentId;
  final String studentName;
  final String? rollNumber;
  final String? className;

  @override
  ConsumerState<StudentExamHistoryScreen> createState() =>
      _StudentExamHistoryScreenState();
}

class _StudentExamHistoryScreenState
    extends ConsumerState<StudentExamHistoryScreen> {
  Future<StudentExamHistoryResponse>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final repo = ref.read(examRepositoryProvider);
    setState(() {
      _historyFuture = repo.getStudentExamHistory(widget.studentId);
    });
  }

  Future<void> _exportReportCard(StudentExamResult item) async {
    try {
      final pdfBytes = await ReportPdfService.instance
          .generateStudentReportCardPdf(
        item,
        className: widget.className,
      );
      if (!mounted) return;
      await ReportPdfService.instance.previewOrPrintPdf(
        context,
        pdfBytes,
        title: '${widget.studentName} - ${item.examTitle}',
        fileName: '${widget.studentName}_${item.examTitle}_Report_Card.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate report card: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampusPage(
      appBar: AppBar(
        title: Text('${widget.studentName} — Exam History'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: CampusScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Banner Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFD3CCE8)),
              ),
              color: const Color(0xFFF7F5FC),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: CampusStyle.primary,
                      child: Text(
                        widget.studentName.isNotEmpty
                            ? widget.studentName[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: CampusStyle.ink,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              if (widget.rollNumber != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.tag_rounded,
                                        size: 15,
                                        color: AppColors.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Roll No: ${widget.rollNumber}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              if (widget.className != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.class_rounded,
                                        size: 15,
                                        color: AppColors.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.className!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Exam History Section
            FutureBuilder<StudentExamHistoryResponse>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  final errorMsg =
                      snapshot.error.toString().replaceFirst('Exception: ', '');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 48, color: Colors.red.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load exam history',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            errorMsg,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _loadHistory,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final results = snapshot.data?.items ?? [];

                if (results.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_edu_rounded,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No Examination Records',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: CampusStyle.ink,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'This student does not have any recorded exam marks yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return _buildExamRecordCard(item);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamRecordCard(StudentExamResult item) {
    final pct = item.percentage;
    final isPassed = pct >= 33.0; // Server standard

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isPassed ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2),
          width: 1.2,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Exam Title & Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.examTitle,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: CampusStyle.ink,
                            ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('Report Card PDF', style: TextStyle(fontSize: 12)),
                  onPressed: () => _exportReportCard(item),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.examStatus == ExamStatus.published
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: item.examStatus == ExamStatus.published
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                    ),
                  ),
                  child: Text(
                    item.examStatus == ExamStatus.published
                        ? 'Published'
                        : 'Draft',
                    style: TextStyle(
                      color: item.examStatus == ExamStatus.published
                          ? Colors.green.shade900
                          : Colors.orange.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Performance Metrics Grid
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F8FD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEDE9F6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricColumn(
                    'Marks',
                    '${item.totalObtained.toStringAsFixed(1)} / ${item.totalMaximum.toStringAsFixed(0)}',
                    CampusStyle.ink,
                  ),
                  _buildMetricColumn(
                    'Percentage',
                    '${pct.toStringAsFixed(1)}%',
                    isPassed ? const Color(0xFF2E7D32) : Colors.red.shade700,
                  ),
                  _buildMetricColumn(
                    'Result',
                    isPassed ? 'PASS' : 'FAIL',
                    isPassed ? const Color(0xFF2E7D32) : Colors.red.shade700,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subject Marks Table
            const Text(
              'Subject Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: CampusStyle.ink,
              ),
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 38,
                    dataRowMinHeight: 38,
                    dataRowMaxHeight: 46,
                    columns: const [
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Marks')),
                      DataColumn(label: Text('Max')),
                      DataColumn(label: Text('Pass')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: item.subjectResults.map((s) {
                      final isSubjectAbsent = s.isAbsent;
                      final isSubjectPassed = !isSubjectAbsent &&
                          s.marksObtained != null &&
                          s.marksObtained! >= s.passingMarks;

                      return DataRow(
                        cells: [
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.subjectName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                if (s.remarks != null && s.remarks!.isNotEmpty)
                                  Text(
                                    s.remarks!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blueGrey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              isSubjectAbsent
                                  ? 'ABSENT'
                                  : (s.marksObtained?.toStringAsFixed(1) ?? '—'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSubjectAbsent
                                    ? Colors.red
                                    : (isSubjectPassed
                                        ? CampusStyle.ink
                                        : Colors.red),
                              ),
                            ),
                          ),
                          DataCell(Text(s.maxMarks.toStringAsFixed(0))),
                          DataCell(Text(s.passingMarks.toStringAsFixed(0))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSubjectAbsent
                                    ? Colors.red.shade50
                                    : (isSubjectPassed
                                        ? Colors.green.shade50
                                        : Colors.red.shade50),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isSubjectAbsent
                                    ? 'Absent'
                                    : (isSubjectPassed ? 'Pass' : 'Fail'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSubjectAbsent
                                      ? Colors.red.shade800
                                      : (isSubjectPassed
                                          ? Colors.green.shade800
                                          : Colors.red.shade800),
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
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
