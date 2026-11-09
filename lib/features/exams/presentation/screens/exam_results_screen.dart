import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/models/exam_results_model.dart';
import 'package:cms/features/exams/presentation/screens/student_exam_history_screen.dart';
import 'package:cms/features/exams/presentation/widgets/correct_exam_result_dialog.dart';
import 'package:cms/features/reports/services/report_pdf_service.dart';

class ExamResultsScreen extends ConsumerStatefulWidget {
  final String examId;
  final String examTitle;
  final bool isReadOnly;

  const ExamResultsScreen({
    super.key,
    required this.examId,
    required this.examTitle,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends ConsumerState<ExamResultsScreen> {
  bool _isLoading = true;
  bool _isExporting = false;
  String? _errorMessage;
  String _searchQuery = '';
  ExamClassResults? _results;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(examRepositoryProvider);
      final res = await repo.getClassResults(widget.examId);
      setState(() {
        _results = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _exportClassResultsPdf() async {
    if (_results == null) return;
    setState(() => _isExporting = true);
    try {
      final scope = '${widget.examTitle} (${_results!.academicYear})';
      final pdfBytes = await ReportPdfService.instance
          .generateClassResultsPdf(_results!, scopeDescription: scope);
      if (!mounted) return;
      await ReportPdfService.instance.previewOrPrintPdf(
        context,
        pdfBytes,
        title: '${widget.examTitle} - Merit List',
        fileName: '${widget.examTitle}_Class_Merit_Roster.pdf',
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

  Future<void> _exportStudentReportCard(ExamClassResultStudent st) async {
    if (_results == null) return;
    try {
      final studentResult = st.toStudentExamResult(
        examId: _results!.examId,
        examTitle: _results!.examTitle,
        examStatus: _results!.examStatus,
      );
      final pdfBytes = await ReportPdfService.instance
          .generateStudentReportCardPdf(
        studentResult,
        academicYear: _results!.academicYear,
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
    final filtered = (_results?.students ?? []).where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.studentName.toLowerCase().contains(_searchQuery) ||
          s.rollNumber.toLowerCase().contains(_searchQuery);
    }).toList();

    double avgPct = 0.0;
    double topPct = 0.0;
    if (_results != null && _results!.students.isNotEmpty) {
      final sum = _results!.students.fold<double>(0.0, (acc, s) => acc + s.percentage);
      avgPct = sum / _results!.students.length;
      topPct = _results!.students.map((s) => s.percentage).reduce((a, b) => a > b ? a : b);
    }

    return CampusPage(
      appBar: AppBar(
        title: Text('${widget.examTitle} — Results'),
        actions: [
          if (_results != null)
            IconButton(
              tooltip: 'Export Class Merit List PDF',
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
              onPressed: _isExporting ? null : _exportClassResultsPdf,
            ),
          IconButton(
            tooltip: 'Refresh Results',
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadResults,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadResults,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _results == null
                  ? const Center(child: Text('No results found.'))
                  : CampusScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // KPI Metric Cards
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 600;
                              final cardWidth = isMobile
                                  ? (constraints.maxWidth - 12) / 2
                                  : (constraints.maxWidth - 24) / 3;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: cardWidth,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: CampusStyle.card,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'TOTAL STUDENTS',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: CampusStyle.muted,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${_results!.students.length}',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: CampusStyle.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: CampusStyle.card,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'CLASS AVERAGE',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: CampusStyle.muted,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${avgPct.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isMobile ? constraints.maxWidth : cardWidth,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: CampusStyle.card,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'HIGHEST SCORE',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: CampusStyle.muted,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${topPct.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondary,
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
                          const SizedBox(height: 16),

                          // Search Filter
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search student name or roll #...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (v) =>
                                setState(() => _searchQuery = v.trim().toLowerCase()),
                          ),
                          const SizedBox(height: 16),

                          // Students Results Cards
                          if (filtered.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: CampusStyle.card,
                              child: const Center(
                                child: Text('No student records match the search criteria.'),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, idx) {
                                final st = filtered[idx];
                                final isPassed = st.percentage >= 33.0; // standard passing benchmark
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: CampusStyle.card,
                                  child: ExpansionTile(
                                    tilePadding: EdgeInsets.zero,
                                    childrenPadding: const EdgeInsets.only(top: 12),
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: isPassed
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      child: Text(
                                        st.rollNumber,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isPassed
                                              ? Colors.green.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      st.studentName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Obtained: ${st.totalObtained.toStringAsFixed(1)} / ${st.totalMaximum.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CampusStyle.muted,
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPassed
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isPassed
                                              ? Colors.green.shade300
                                              : Colors.red.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        '${st.percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isPassed
                                              ? Colors.green.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                    children: [
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Subject Breakdown:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 6,
                                            children: [
                                              TextButton.icon(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                                                label: const Text('Report Card PDF', style: TextStyle(fontSize: 12)),
                                                onPressed: () => _exportStudentReportCard(st),
                                              ),
                                              TextButton.icon(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                                icon: const Icon(Icons.history_rounded, size: 16),
                                                label: const Text('All Exams History', style: TextStyle(fontSize: 12)),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => StudentExamHistoryScreen(
                                                        studentId: st.studentId,
                                                        studentName: st.studentName,
                                                        rollNumber: st.rollNumber,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ...st.subjectResults.map((subMark) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      subMark.subjectName,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Max: ${subMark.maxMarks.toStringAsFixed(0)} | Pass: ${subMark.passingMarks.toStringAsFixed(0)}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: CampusStyle.muted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                subMark.isAbsent
                                                    ? 'ABSENT'
                                                    : subMark.marksObtained?.toStringAsFixed(1) ?? '0',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: subMark.isAbsent
                                                      ? Colors.red
                                                      : CampusStyle.primary,
                                                ),
                                              ),
                                              if (!widget.isReadOnly) ...[
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  tooltip: 'Correct this mark',
                                                  icon: const Icon(
                                                    Icons.edit_note_rounded,
                                                    color: CampusStyle.primary,
                                                    size: 22,
                                                  ),
                                                  onPressed: () async {
                                                    final updated =
                                                        await CorrectExamResultDialog.show(
                                                      context,
                                                      examId: widget.examId,
                                                      studentName: st.studentName,
                                                      rollNumber: st.rollNumber,
                                                      mark: subMark,
                                                    );
                                                    if (updated == true) {
                                                      _loadResults();
                                                    }
                                                  },
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
    );
  }
}
