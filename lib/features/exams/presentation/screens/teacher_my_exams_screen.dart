import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/exams/presentation/screens/enter_marks_grid_screen.dart';
import 'package:cms/features/exams/presentation/screens/exam_results_screen.dart';
import 'package:cms/features/exams/presentation/screens/exam_subjects_screen.dart';
import 'package:cms/features/exams/presentation/widgets/create_exam_dialog.dart';

class TeacherMyExamsScreen extends ConsumerStatefulWidget {
  const TeacherMyExamsScreen({super.key});

  @override
  ConsumerState<TeacherMyExamsScreen> createState() => _TeacherMyExamsScreenState();
}

class _TeacherMyExamsScreenState extends ConsumerState<TeacherMyExamsScreen> {
  String _selectedStatusFilter = 'all'; // 'all', 'draft', 'published'
  String _searchQuery = '';
  final _searchController = TextEditingController();

  Future<ExamListResponse>? _examsFuture;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadExams() {
    final repo = ref.read(examRepositoryProvider);
    setState(() {
      _examsFuture = repo.listExams(page: 1, limit: 100);
    });
  }

  Future<void> _openCreateExamDialog() async {
    final created = await CreateExamDialog.show(context, isTeacherMode: true);
    if (created != null) {
      _loadExams();
    }
  }

  String _formatExamType(ExamType type) {
    switch (type) {
      case ExamType.midTerm:
        return 'Mid Term';
      case ExamType.finalTerm:
        return 'Final Term';
      case ExamType.regular:
        return 'Regular Assessment';
    }
  }

  Color _getExamTypeColor(ExamType type) {
    switch (type) {
      case ExamType.midTerm:
        return const Color(0xFF1E88E5);
      case ExamType.finalTerm:
        return const Color(0xFF8E24AA);
      case ExamType.regular:
        return const Color(0xFF00897B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampusPage(
      appBar: AppBar(
        title: const Text('My Class Examinations'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadExams,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateExamDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Exam'),
        backgroundColor: CampusStyle.primary,
        foregroundColor: Colors.white,
      ),
      body: CampusScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro
            const CampusSectionIntro(
              title: 'Examinations & Marks',
              subtitle:
                  'Manage exams, enter marks for your class, and publish finalized results.',
            ),
            const SizedBox(height: 16),

            // Filter bar
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Search box
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search exams by title or term...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                    const SizedBox(height: 10),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Statuses'),
                            selected: _selectedStatusFilter == 'all',
                            onSelected: (sel) {
                              if (sel) setState(() => _selectedStatusFilter = 'all');
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_note_rounded,
                                    size: 16, color: Colors.orange),
                                SizedBox(width: 4),
                                Text('Drafts'),
                              ],
                            ),
                            selected: _selectedStatusFilter == 'draft',
                            onSelected: (sel) {
                              if (sel) setState(() => _selectedStatusFilter = 'draft');
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 16, color: Colors.green),
                                SizedBox(width: 4),
                                Text('Published'),
                              ],
                            ),
                            selected: _selectedStatusFilter == 'published',
                            onSelected: (sel) {
                              if (sel) {
                                setState(() => _selectedStatusFilter = 'published');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Exam List
            FutureBuilder<ExamListResponse>(
              future: _examsFuture,
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
                            'Failed to load examinations',
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
                            onPressed: _loadExams,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final examList = snapshot.data?.items ?? [];

                // Filter items
                final filtered = examList.where((e) {
                  if (_selectedStatusFilter == 'draft' &&
                      e.status != ExamStatus.draft) {
                    return false;
                  }
                  if (_selectedStatusFilter == 'published' &&
                      e.status != ExamStatus.published) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    final titleMatch = e.title.toLowerCase().contains(q);
                    final termMatch =
                        e.termName?.toLowerCase().contains(q) ?? false;
                    final yearMatch = e.academicYear.toLowerCase().contains(q);
                    if (!titleMatch && !termMatch && !yearMatch) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 48, horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            examList.isEmpty
                                ? 'No examinations scheduled yet'
                                : 'No matching exams found',
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
                            examList.isEmpty
                                ? 'Schedule your first exam to configure subjects and enter student marks.'
                                : 'Try adjusting your search terms or filter selection.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 20),
                          if (examList.isEmpty)
                            FilledButton.icon(
                              onPressed: _openCreateExamDialog,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Create Exam'),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 720;
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final exam = filtered[index];
                        return _buildExamCard(exam, isDesktop);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(Exam exam, bool isDesktop) {
    final isDraft = exam.status == ExamStatus.draft;
    final typeColor = _getExamTypeColor(exam.examType);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDraft ? const Color(0xFFE2DDF5) : const Color(0xFFC8E6C9),
          width: 1.2,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type Pill, Status Badge, Academic Year
            Row(
              children: [
                // Exam Type Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatExamType(exam.examType),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Status Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDraft
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDraft
                          ? Colors.orange.shade300
                          : Colors.green.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDraft
                            ? Icons.edit_note_rounded
                            : Icons.check_circle_rounded,
                        size: 14,
                        color: isDraft
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDraft ? 'Draft' : 'Published',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDraft
                              ? Colors.orange.shade900
                              : Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Academic Year Pill
                Text(
                  exam.academicYear,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exam Title
            Text(
              exam.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CampusStyle.ink,
                  ),
            ),
            if (exam.termName != null && exam.termName!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                exam.termName!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Metadata Row: Date & Student Count
            Row(
              children: [
                if (exam.examDate != null) ...[
                  Icon(Icons.calendar_today_rounded,
                      size: 15, color: Colors.grey.shade600),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(exam.examDate!)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(Icons.groups_rounded,
                    size: 17, color: CampusStyle.primary),
                const SizedBox(width: 5),
                Text(
                  '${exam.studentCount} Students',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CampusStyle.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Subject Configuration button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => ExamSubjectsScreen(
                              examId: exam.id,
                              examTitle: exam.title,
                              isPublished: !isDraft,
                            ),
                          ),
                        )
                        .then((_) => _loadExams());
                  },
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: Text(isDraft ? 'Subjects' : 'View Subjects'),
                ),

                // Draft Actions: Enter Marks
                if (isDraft)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => EnterMarksGridScreen(
                                examId: exam.id,
                                examTitle: exam.title,
                              ),
                            ),
                          )
                          .then((_) => _loadExams());
                    },
                    icon: const Icon(Icons.table_chart_rounded, size: 16),
                    label: const Text('Enter Marks'),
                  ),

                // Published Actions: View Results & Correct Mark
                if (!isDraft) ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExamResultsScreen(
                            examId: exam.id,
                            examTitle: exam.title,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics_rounded, size: 16),
                    label: const Text('Results & Merit'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExamResultsScreen(
                            examId: exam.id,
                            examTitle: exam.title,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Correct Mark'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
