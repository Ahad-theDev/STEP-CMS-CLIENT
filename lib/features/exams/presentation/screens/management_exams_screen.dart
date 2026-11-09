import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/features/auth/application/auth_controller.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/exams/presentation/screens/enter_marks_grid_screen.dart';
import 'package:cms/features/exams/presentation/screens/exam_results_screen.dart';
import 'package:cms/features/exams/presentation/screens/exam_subjects_screen.dart';
import 'package:cms/features/exams/presentation/widgets/create_exam_dialog.dart';

class ManagementExamsScreen extends ConsumerStatefulWidget {
  const ManagementExamsScreen({
    super.key,
    this.isPrincipalReadOnly = false,
  });

  final bool isPrincipalReadOnly;

  @override
  ConsumerState<ManagementExamsScreen> createState() =>
      _ManagementExamsScreenState();
}

class _ManagementExamsScreenState extends ConsumerState<ManagementExamsScreen> {
  String? _selectedClassId; // null = all classes
  String _selectedStatusFilter = 'all'; // 'all', 'draft', 'published'
  String _searchQuery = '';
  final _searchController = TextEditingController();

  Future<ExamListResponse>? _examsFuture;

  @override
  void initState() {
    super.initState();
    // If principal, default filter to published
    if (widget.isPrincipalReadOnly) {
      _selectedStatusFilter = 'published';
    }
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
      _examsFuture = repo.listExams(
        classId: _selectedClassId,
        page: 1,
        limit: 100,
      );
    });
  }

  Future<void> _openCreateExamDialog() async {
    final created = await CreateExamDialog.show(
      context,
      preselectedClassId: _selectedClassId,
      isTeacherMode: false,
    );
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
    final signedInUser = ref.read(authControllerProvider.notifier).signedInUser;
    final userRole = signedInUser?.role ?? '';
    final isPrincipal =
        widget.isPrincipalReadOnly || userRole.toLowerCase() == 'principal';

    final classesAsync = ref.watch(allClassesControllerProvider);

    return CampusPage(
      appBar: AppBar(
        title: Text(isPrincipal ? 'Examinations (Principal View)' : 'All Examinations'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadExams,
          ),
        ],
      ),
      floatingActionButton: !isPrincipal
          ? FloatingActionButton.extended(
              onPressed: _openCreateExamDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Exam'),
              backgroundColor: CampusStyle.primary,
              foregroundColor: Colors.white,
            )
          : null,
      body: CampusScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro
            CampusSectionIntro(
              title: isPrincipal
                  ? 'Official Examinations Overview'
                  : 'Institution Examinations & Results',
              subtitle: isPrincipal
                  ? 'Review verified, published academic examinations, class merit rankings, and performance stats.'
                  : 'Manage term exams across all school classes, track marks entry, and publish results.',
            ),
            const SizedBox(height: 16),

            // Filter Card: Class Selector, Search & Status Filter
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Class Selector & Search row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 600;
                        final classDropdown = classesAsync.when(
                          data: (classes) {
                            final activeClasses =
                                classes.where((c) => c.isActive).toList();
                            return DropdownButtonFormField<String?>(
                              initialValue: _selectedClassId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Filter by Class',
                                prefixIcon: Icon(Icons.class_rounded),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
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
                              onChanged: (val) {
                                setState(() => _selectedClassId = val);
                                _loadExams();
                              },
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Failed to load classes: $e'),
                        );

                        final searchBox = TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by title or term...',
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
                                horizontal: 14, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          onChanged: (val) =>
                              setState(() => _searchQuery = val.trim()),
                        );

                        if (isDesktop) {
                          return Row(
                            children: [
                              Expanded(flex: 3, child: classDropdown),
                              const SizedBox(width: 12),
                              Expanded(flex: 4, child: searchBox),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              classDropdown,
                              const SizedBox(height: 10),
                              searchBox,
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Status Chips (Hidden or locked if Principal)
                    if (!isPrincipal)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('All Statuses'),
                              selected: _selectedStatusFilter == 'all',
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() => _selectedStatusFilter = 'all');
                                }
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
                                if (sel) {
                                  setState(() => _selectedStatusFilter = 'draft');
                                }
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
                                  setState(
                                      () => _selectedStatusFilter = 'published');
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                size: 16, color: Colors.green.shade800),
                            const SizedBox(width: 6),
                            Text(
                              'Showing Published Official Examinations Only',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade900,
                              ),
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

                // Filter
                final filtered = examList.where((e) {
                  if (isPrincipal && e.status != ExamStatus.published) {
                    return false;
                  }
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
                                ? 'No examinations found'
                                : 'No matching exams for current filter',
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
                            examList.isEmpty && !isPrincipal
                                ? 'Tap "Create Exam" to schedule an exam for any active class.'
                                : 'Try clearing your search query or selecting "All Classes".',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 20),
                          if (examList.isEmpty && !isPrincipal)
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
                        return _buildExamCard(exam, isDesktop, isPrincipal);
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

  Widget _buildExamCard(Exam exam, bool isDesktop, bool isPrincipal) {
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
            // Top Row
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

            // Actions Row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Subjects Button (Read-only if Published or Principal)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => ExamSubjectsScreen(
                              examId: exam.id,
                              examTitle: exam.title,
                              isPublished: !isDraft,
                              isReadOnly: isPrincipal,
                            ),
                          ),
                        )
                        .then((_) => _loadExams());
                  },
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: Text((isDraft && !isPrincipal) ? 'Configure Subjects' : 'Subjects'),
                ),

                // Draft Actions: Management can enter marks
                if (isDraft && !isPrincipal)
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

                // Published Actions: View Results (Both Management & Principal)
                if (!isDraft)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExamResultsScreen(
                            examId: exam.id,
                            examTitle: exam.title,
                            isReadOnly: isPrincipal,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics_rounded, size: 16),
                    label: const Text('Results & Merit'),
                  ),

                // Mark Correction (Management only)
                if (!isDraft && !isPrincipal)
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
            ),
          ],
        ),
      ),
    );
  }
}
