import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/models/exam_subject_model.dart';

class ExamSubjectsScreen extends ConsumerStatefulWidget {
  final String examId;
  final String examTitle;
  final bool isPublished;
  final bool isReadOnly;

  const ExamSubjectsScreen({
    super.key,
    required this.examId,
    required this.examTitle,
    this.isPublished = false,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<ExamSubjectsScreen> createState() => _ExamSubjectsScreenState();
}

class _SubjectRowDraft {
  String? id;
  String? subjectId;
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController maxMarksController;
  final TextEditingController passMarksController;
  int displayOrder;

  _SubjectRowDraft({
    this.id,
    this.subjectId,
    required String name,
    String? code,
    required double maxMarks,
    required double passMarks,
    this.displayOrder = 0,
  })  : nameController = TextEditingController(text: name),
        codeController = TextEditingController(text: code ?? ''),
        maxMarksController = TextEditingController(text: maxMarks.toString()),
        passMarksController = TextEditingController(text: passMarks.toString());

  void dispose() {
    nameController.dispose();
    codeController.dispose();
    maxMarksController.dispose();
    passMarksController.dispose();
  }
}

class _ExamSubjectsScreenState extends ConsumerState<ExamSubjectsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  final List<_SubjectRowDraft> _rows = [];

  bool get _locked => widget.isPublished || widget.isReadOnly;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(examRepositoryProvider);
      final details = await repo.getExamDetails(widget.examId);

      for (final r in _rows) {
        r.dispose();
      }
      _rows.clear();

      for (final s in details.subjects) {
        _rows.add(
          _SubjectRowDraft(
            id: s.id,
            subjectId: s.subjectId,
            name: s.subjectName,
            code: s.subjectCode,
            maxMarks: s.maxMarks,
            passMarks: s.passingMarks,
            displayOrder: s.displayOrder,
          ),
        );
      }

      if (_rows.isEmpty && !_locked) {
        // Pre-add a default empty row for convenience
        _addNewSubjectRow();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _addNewSubjectRow() {
    setState(() {
      _rows.add(
        _SubjectRowDraft(
          name: '',
          code: '',
          maxMarks: 100.0,
          passMarks: 33.0,
          displayOrder: _rows.length + 1,
        ),
      );
    });
  }

  void _removeSubjectRow(int index) {
    setState(() {
      final removed = _rows.removeAt(index);
      removed.dispose();
      for (var i = 0; i < _rows.length; i++) {
        _rows[i].displayOrder = i + 1;
      }
    });
  }

  Future<void> _saveSubjects() async {
    if (_rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one subject.')),
      );
      return;
    }

    final subjectsToSave = <ExamSubjectUpdate>[];
    final namesSeen = <String>{};

    for (var i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      final name = row.nameController.text.trim();
      if (name.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject #${i + 1} must have a name (min 2 chars).')),
        );
        return;
      }
      if (namesSeen.contains(name.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Duplicate subject name: "$name"')),
        );
        return;
      }
      namesSeen.add(name.toLowerCase());

      final maxMarks = double.tryParse(row.maxMarksController.text.trim());
      if (maxMarks == null || maxMarks <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject "$name" maximum marks must be greater than 0.')),
        );
        return;
      }

      final passMarks = double.tryParse(row.passMarksController.text.trim());
      if (passMarks == null || passMarks < 0 || passMarks > maxMarks) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject "$name" passing marks must be between 0 and $maxMarks.')),
        );
        return;
      }

      subjectsToSave.add(
        ExamSubjectUpdate(
          id: row.id,
          subjectId: row.subjectId,
          subjectName: name,
          subjectCode: row.codeController.text.trim().isNotEmpty
              ? row.codeController.text.trim()
              : null,
          maxMarks: maxMarks,
          passingMarks: passMarks,
          displayOrder: i + 1,
        ),
      );
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(examRepositoryProvider);
      await repo.replaceSubjects(widget.examId, subjectsToSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subjects configuration saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSubjects();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save subjects: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampusPage(
      appBar: AppBar(
        title: Text(widget.examTitle),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading || _isSaving ? null : _loadSubjects,
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
                        FilledButton.icon(
                          onPressed: _loadSubjects,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : CampusScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: CampusStyle.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.menu_book_rounded, color: CampusStyle.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Subject Configuration',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: widget.isPublished
                                        ? Colors.green.shade50
                                        : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: widget.isPublished
                                          ? Colors.green.shade300
                                          : Colors.amber.shade400,
                                    ),
                                  ),
                                  child: Text(
                                    widget.isPublished ? 'Published • Locked' : 'Draft • Editable',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: widget.isPublished
                                          ? Colors.green.shade800
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _locked
                                  ? 'Subject configuration is locked because this exam has been published.'
                                  : 'Configure the subjects, maximum marks, and passing thresholds for this exam.',
                              style: const TextStyle(color: CampusStyle.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subjects List
                      if (_rows.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: CampusStyle.card,
                          child: const Center(
                            child: Text('No subjects added yet.'),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _rows.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final row = _rows[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: CampusStyle.card,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: CampusStyle.primary.withValues(alpha: 0.12),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: CampusStyle.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Subject #${index + 1}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      if (!_locked)
                                        IconButton(
                                          tooltip: 'Remove Subject',
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _removeSubjectRow(index),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isMobile = constraints.maxWidth < 600;
                                      return Wrap(
                                        spacing: 12,
                                        runSpacing: 10,
                                        children: [
                                          SizedBox(
                                            width: isMobile
                                                ? constraints.maxWidth
                                                : (constraints.maxWidth - 36) * 0.45,
                                            child: TextField(
                                              controller: row.nameController,
                                              enabled: !_locked,
                                              decoration: const InputDecoration(
                                                labelText: 'Subject Name (e.g. English)*',
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: isMobile
                                                ? (constraints.maxWidth - 12) / 2
                                                : (constraints.maxWidth - 36) * 0.20,
                                            child: TextField(
                                              controller: row.codeController,
                                              enabled: !_locked,
                                              decoration: const InputDecoration(
                                                labelText: 'Code (e.g. ENG)',
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: isMobile
                                                ? (constraints.maxWidth - 12) / 2
                                                : (constraints.maxWidth - 36) * 0.175,
                                            child: TextField(
                                              controller: row.maxMarksController,
                                              enabled: !_locked,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              decoration: const InputDecoration(
                                                labelText: 'Max Marks*',
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: isMobile
                                                ? constraints.maxWidth
                                                : (constraints.maxWidth - 36) * 0.175,
                                            child: TextField(
                                              controller: row.passMarksController,
                                              enabled: !_locked,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              decoration: const InputDecoration(
                                                labelText: 'Pass Marks*',
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
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
                            );
                          },
                        ),
                      const SizedBox(height: 16),

                      // Action buttons
                      if (!_locked) ...[
                        OutlinedButton.icon(
                          onPressed: _isSaving ? null : _addNewSubjectRow,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Another Subject'),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isSaving ? null : _saveSubjects,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(_isSaving ? 'Saving...' : 'Save Subject Configuration'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
