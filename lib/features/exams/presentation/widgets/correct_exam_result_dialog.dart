import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/models/exam_correction_model.dart';
import 'package:cms/features/exams/data/models/exam_marks_grid_model.dart';

class CorrectExamResultDialog extends ConsumerStatefulWidget {
  final String examId;
  final String studentName;
  final String rollNumber;
  final GridMark mark;

  const CorrectExamResultDialog({
    super.key,
    required this.examId,
    required this.studentName,
    required this.rollNumber,
    required this.mark,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String examId,
    required String studentName,
    required String rollNumber,
    required GridMark mark,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CorrectExamResultDialog(
        examId: examId,
        studentName: studentName,
        rollNumber: rollNumber,
        mark: mark,
      ),
    );
  }

  @override
  ConsumerState<CorrectExamResultDialog> createState() =>
      _CorrectExamResultDialogState();
}

class _CorrectExamResultDialogState
    extends ConsumerState<CorrectExamResultDialog> {
  late final TextEditingController _marksController;
  late final TextEditingController _reasonController;
  late bool _isAbsent;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isAbsent = widget.mark.isAbsent;
    _marksController = TextEditingController(
      text: widget.mark.marksObtained?.toString() ?? '0',
    );
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _marksController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _showAuditHistory() async {
    final repo = ref.read(examRepositoryProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Correction History — ${widget.mark.subjectName}'),
        content: SizedBox(
          width: 480,
          height: 320,
          child: FutureBuilder<List<ExamResultAudit>>(
            future: repo.getResultAudit(widget.examId, widget.mark.examSubjectId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load history: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              final audits = snapshot.data ?? [];
              if (audits.isEmpty) {
                return const Center(
                  child: Text('No previous corrections found for this result.'),
                );
              }
              return ListView.separated(
                itemCount: audits.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, idx) {
                  final a = audits[idx];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Text(
                          '${a.oldIsAbsent ? "Absent" : a.oldMarks} ➔ ${a.newIsAbsent ? "Absent" : a.newMarks}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CampusStyle.primary,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Reason: ${a.reason}'),
                        const SizedBox(height: 2),
                        Text(
                          'Date: ${a.changedAt}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: CampusStyle.muted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.length < 3) {
      setState(() => _error = 'Please enter a valid correction reason (min 3 characters).');
      return;
    }

    double newMarks = 0.0;
    if (!_isAbsent) {
      final parsed = double.tryParse(_marksController.text.trim());
      if (parsed == null || parsed < 0) {
        setState(() => _error = 'Please enter valid non-negative marks.');
        return;
      }
      if (parsed > widget.mark.maxMarks) {
        setState(() => _error = 'Marks cannot exceed maximum (${widget.mark.maxMarks}).');
        return;
      }
      newMarks = parsed;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final repo = ref.read(examRepositoryProvider);
      await repo.correctResult(
        widget.examId,
        widget.mark.examSubjectId,
        ExamResultCorrection(
          marksObtained: newMarks,
          isAbsent: _isAbsent,
          reason: reason,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Correct Exam Mark', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${widget.studentName} (Roll #${widget.rollNumber}) — ${widget.mark.subjectName}',
            style: const TextStyle(fontSize: 13, color: CampusStyle.muted),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Checkbox(
                    value: _isAbsent,
                    onChanged: (val) {
                      setState(() {
                        _isAbsent = val ?? false;
                        if (_isAbsent) {
                          _marksController.text = '0';
                        }
                      });
                    },
                  ),
                  const Text('Mark as Absent (Zero marks)'),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _marksController,
                enabled: !_isAbsent,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Marks Obtained (Max: ${widget.mark.maxMarks})',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: _isAbsent ? Colors.grey.shade100 : Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Correction Reason (Required)*',
                  hintText: 'e.g. Recounting verified by teacher',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _showAuditHistory,
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('View Audit History'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save Correction'),
        ),
      ],
    );
  }
}
