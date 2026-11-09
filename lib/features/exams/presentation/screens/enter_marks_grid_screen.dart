import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/exams/data/models/exam_marks_grid_model.dart';
import 'package:cms/features/exams/data/models/bulk_marks_save_request.dart';
import 'package:cms/features/exams/presentation/screens/exam_results_screen.dart';

class EnterMarksGridScreen extends ConsumerStatefulWidget {
  final String examId;
  final String examTitle;
  final bool isReadOnly;

  const EnterMarksGridScreen({
    super.key,
    required this.examId,
    required this.examTitle,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<EnterMarksGridScreen> createState() =>
      _EnterMarksGridScreenState();
}

class _StudentGridState {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final Map<String, _CellState> cells; // examSubjectId -> _CellState

  _StudentGridState({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.cells,
  });
}

class _CellState {
  final String examSubjectId;
  final double maxMarks;
  final double passingMarks;
  final TextEditingController controller;
  bool isAbsent;

  _CellState({
    required this.examSubjectId,
    required this.maxMarks,
    required this.passingMarks,
    double? initialMarks,
    this.isAbsent = false,
  }) : controller = TextEditingController(
          text: initialMarks != null
              ? (initialMarks % 1 == 0
                  ? initialMarks.toInt().toString()
                  : initialMarks.toString())
              : '',
        );

  void dispose() {
    controller.dispose();
  }
}

class _EnterMarksGridScreenState extends ConsumerState<EnterMarksGridScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';

  ExamMarksGrid? _gridData;
  final List<_StudentGridState> _students = [];

  bool get _locked =>
      widget.isReadOnly || (_gridData?.examStatus == ExamStatus.published);

  @override
  void initState() {
    super.initState();
    _loadGrid();
  }

  @override
  void dispose() {
    for (final s in _students) {
      for (final c in s.cells.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadGrid() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(examRepositoryProvider);
      final grid = await repo.getMarksGrid(widget.examId);

      for (final s in _students) {
        for (final c in s.cells.values) {
          c.dispose();
        }
      }
      _students.clear();

      for (final student in grid.students) {
        final cellMap = <String, _CellState>{};
        for (final m in student.marks) {
          cellMap[m.examSubjectId] = _CellState(
            examSubjectId: m.examSubjectId,
            maxMarks: m.maxMarks,
            passingMarks: m.passingMarks,
            initialMarks: m.marksObtained,
            isAbsent: m.isAbsent,
          );
        }
        _students.add(
          _StudentGridState(
            studentId: student.studentId,
            studentName: student.studentName,
            rollNumber: student.rollNumber,
            cells: cellMap,
          ),
        );
      }

      setState(() {
        _gridData = grid;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _onSaveAllTapped() async {
    if (_gridData == null || _students.isEmpty) return;

    // Check completeness
    int incompleteCount = 0;
    for (final s in _students) {
      for (final subj in _gridData!.subjects) {
        final cell = s.cells[subj.id];
        if (cell == null) {
          incompleteCount++;
          continue;
        }
        if (!cell.isAbsent && cell.controller.text.trim().isEmpty) {
          incompleteCount++;
        }
      }
    }

    if (incompleteCount > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Incomplete Marks Grid'),
          content: Text(
            'There are $incompleteCount student-subject marks not entered yet.\n\n'
            'The backend requires a complete grid to submit. Please enter marks or check "Absent" for all students.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Validate ranges
    for (final s in _students) {
      for (final subj in _gridData!.subjects) {
        final cell = s.cells[subj.id];
        if (cell != null && !cell.isAbsent) {
          final marks = double.tryParse(cell.controller.text.trim());
          if (marks == null || marks < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid mark for ${s.studentName} in ${subj.subjectName}'),
              ),
            );
            return;
          }
          if (marks > subj.maxMarks) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Mark $marks for ${s.studentName} exceeds max marks (${subj.maxMarks}) in ${subj.subjectName}',
                ),
              ),
            );
            return;
          }
        }
      }
    }

    // Show Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish Results Confirmation'),
        content: const Text(
          'Are you sure?\n\n'
          'Saving all marks will publish the exam results. Once published, subject configuration is locked and individual marks can only be changed with an audit reason.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm & Publish'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Build Payload
    final entries = <StudentMarksEntry>[];
    for (final s in _students) {
      final subjectEntries = <StudentSubjectMarkEntry>[];
      for (final subj in _gridData!.subjects) {
        final cell = s.cells[subj.id]!;
        final markValue = cell.isAbsent
            ? 0.0
            : (double.tryParse(cell.controller.text.trim()) ?? 0.0);
        subjectEntries.add(
          StudentSubjectMarkEntry(
            examSubjectId: subj.id,
            marksObtained: markValue,
            isAbsent: cell.isAbsent,
          ),
        );
      }
      entries.add(
        StudentMarksEntry(studentId: s.studentId, marks: subjectEntries),
      );
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(examRepositoryProvider);
      final resp = await repo.saveAllMarks(
        widget.examId,
        BulkExamMarksRequest(entries: entries),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.message),
            backgroundColor: Colors.green,
          ),
        );
        // Replace with Results Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ExamResultsScreen(
              examId: widget.examId,
              examTitle: widget.examTitle,
              isReadOnly: widget.isReadOnly,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save marks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _students.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.studentName.toLowerCase().contains(_searchQuery) ||
          s.rollNumber.toLowerCase().contains(_searchQuery);
    }).toList();

    return CampusPage(
      appBar: AppBar(
        title: Text(widget.examTitle),
        actions: [
          if (_locked)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: const Center(
                child: Text(
                  'Published • Locked',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Refresh Grid',
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading || _isSaving ? null : _loadGrid,
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
                          onPressed: _loadGrid,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _gridData == null || _gridData!.subjects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
                            const SizedBox(height: 12),
                            const Text(
                              'No subjects configured for this exam yet.',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Configure subjects before entering marks.',
                              style: TextStyle(color: CampusStyle.muted),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Search Bar & Filter Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search student name or roll #...',
                                    prefixIcon: const Icon(Icons.search, size: 20),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _searchQuery = v.trim().toLowerCase()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: CampusStyle.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${filteredStudents.length} / ${_students.length} Students',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: CampusStyle.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Spreadsheet Grid
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 18,
                                headingRowHeight: 56,
                                dataRowMinHeight: 64,
                                dataRowMaxHeight: 64,
                                columns: [
                                  const DataColumn(
                                    label: Text(
                                      'Roll #',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Student Name',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ..._gridData!.subjects.map(
                                    (subj) => DataColumn(
                                      label: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            subj.subjectName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Max: ${subj.maxMarks.toStringAsFixed(0)} | Pass: ${subj.passingMarks.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: CampusStyle.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                rows: filteredStudents.map((student) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          student.rollNumber,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          student.studentName,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      ..._gridData!.subjects.map((subj) {
                                        final cell = student.cells[subj.id]!;
                                        return DataCell(
                                          SizedBox(
                                            width: 140,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: cell.controller,
                                                    enabled: !_locked && !cell.isAbsent,
                                                    keyboardType:
                                                        const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: cell.isAbsent
                                                          ? Colors.red
                                                          : Colors.black,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter',
                                                      hintStyle: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      filled: true,
                                                      fillColor: cell.isAbsent
                                                          ? Colors.red.shade50
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Tooltip(
                                                  message: cell.isAbsent
                                                      ? 'Marked Absent'
                                                      : 'Toggle Absent',
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(4),
                                                    onTap: _locked
                                                        ? null
                                                        : () {
                                                            setState(() {
                                                              cell.isAbsent = !cell.isAbsent;
                                                              if (cell.isAbsent) {
                                                                cell.controller.text = '0';
                                                              }
                                                            });
                                                          },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: cell.isAbsent
                                                            ? Colors.red
                                                            : Colors.grey.shade200,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        'A',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                          color: cell.isAbsent
                                                              ? Colors.white
                                                              : Colors.grey.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),

                        // Bottom Actions Bar
                        if (!_locked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                            ),
                            child: SafeArea(
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 18, color: CampusStyle.muted),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Save All publishes the exam and calculates class percentages.',
                                      style: TextStyle(fontSize: 12, color: CampusStyle.muted),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed: _isSaving ? null : _onSaveAllTapped,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.publish_rounded),
                                    label: Text(_isSaving ? 'Publishing...' : 'Save All & Publish'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }
}
