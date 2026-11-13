import 'package:cms/features/attendance/application/daily_attendance_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import 'package:cms/features/exams/application/exam_repository_provider.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/exams/presentation/screens/exam_subjects_screen.dart';

class CreateExamDialog extends ConsumerStatefulWidget {
  const CreateExamDialog({
    super.key,
    this.preselectedClassId,
    this.preselectedClassName,
    this.isTeacherMode = false,
  });

  final String? preselectedClassId;
  final String? preselectedClassName;
  final bool isTeacherMode;

  static Future<Exam?> show(
    BuildContext context, {
    String? preselectedClassId,
    String? preselectedClassName,
    bool isTeacherMode = false,
  }) {
    return showDialog<Exam>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CreateExamDialog(
        preselectedClassId: preselectedClassId,
        preselectedClassName: preselectedClassName,
        isTeacherMode: isTeacherMode,
      ),
    );
  }

  @override
  ConsumerState<CreateExamDialog> createState() => _CreateExamDialogState();
}

class _CreateExamDialogState extends ConsumerState<CreateExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _termNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedClassId;
  ExamType _selectedType = ExamType.midTerm;
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.preselectedClassId;
    final now = DateTime.now();
    final nextYear = now.year + 1;
    _academicYearController.text = '${now.year}-$nextYear';
    _selectedDate = now;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _academicYearController.dispose();
    _termNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.isTeacherMode &&
        !(ref.read(dailyAttendanceClassesProvider).valueOrNull ?? []).any(
          (item) => item.id == _selectedClassId && item.isActive,
        )) {
      setState(() => _errorMessage = 'Select a class assigned to you.');
      return;
    }
    if (_selectedClassId == null || _selectedClassId!.isEmpty) {
      setState(() => _errorMessage = 'Please select a class for this exam.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(examRepositoryProvider);
      final dateStr = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;

      final request = ExamCreateRequest(
        classId: _selectedClassId!,
        title: _titleController.text.trim(),
        examType: _selectedType,
        academicYear: _academicYearController.text.trim(),
        termName: _termNameController.text.trim().isEmpty
            ? null
            : _termNameController.text.trim(),
        examDate: dateStr,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      final created = await repo.createExam(request);

      if (!mounted) return;
      Navigator.of(context).pop(created);

      // Offer to configure subjects immediately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exam "${created.title}" created successfully!'),
          backgroundColor: Colors.green.shade700,
          action: SnackBarAction(
            label: 'Configure Subjects',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExamSubjectsScreen(
                    examId: created.id,
                    examTitle: created.title,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = widget.isTeacherMode
        ? ref.watch(dailyAttendanceClassesProvider)
        : ref.watch(allClassesControllerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CampusStyle.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.post_add_rounded,
                        color: CampusStyle.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Examination',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: CampusStyle.ink,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Schedule a new mid-term, final, or regular exam',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Form Scrollable Fields
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Class Selection
                        if (widget.preselectedClassId != null &&
                            widget.preselectedClassName != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EDF9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD6CEF0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.class_rounded,
                                  color: CampusStyle.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Class: ${widget.preselectedClassName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: CampusStyle.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          classesAsync.when(
                            data: (classList) {
                              final activeClasses = classList
                                  .where((c) => c.isActive)
                                  .toList();
                              if (activeClasses.isEmpty) {
                                return const Text(
                                  'No assigned classes are available.',
                                );
                              }
                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue:
                                    activeClasses.any(
                                      (item) => item.id == _selectedClassId,
                                    )
                                    ? _selectedClassId
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Select Class *',
                                  prefixIcon: Icon(Icons.class_rounded),
                                  border: OutlineInputBorder(),
                                ),
                                items: activeClasses.map((c) {
                                  return DropdownMenuItem<String>(
                                    value: c.id,
                                    child: Text('${c.name} - ${c.section}'),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() {
                                  _selectedClassId = val;
                                  if (val != null) {
                                    _academicYearController.text = activeClasses
                                        .firstWhere((c) => c.id == val)
                                        .academicYear;
                                  }
                                }),
                                validator: (val) => (val == null || val.isEmpty)
                                    ? 'Class is required'
                                    : null,
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (err, _) => Text(
                              'Failed to load classes: $err',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 14),

                        // Title Field
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Exam Title *',
                            hintText: 'e.g. Mid Term Examination 2026',
                            prefixIcon: Icon(Icons.title_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                              ? 'Exam title is required'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Exam Type Dropdown
                        DropdownButtonFormField<ExamType>(
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Exam Type *',
                            prefixIcon: Icon(Icons.category_rounded),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: ExamType.midTerm,
                              child: Text('Mid Term'),
                            ),
                            DropdownMenuItem(
                              value: ExamType.finalTerm,
                              child: Text('Final Term'),
                            ),
                            DropdownMenuItem(
                              value: ExamType.regular,
                              child: Text('Regular Assessment / Test'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedType = val);
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        // Academic Year & Term Name Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _academicYearController,
                                decoration: const InputDecoration(
                                  labelText: 'Academic Year *',
                                  hintText: '2026-2027',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _termNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Term Name',
                                  hintText: 'First Term (optional)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Exam Date Field
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Exam Date',
                              prefixIcon: Icon(Icons.calendar_today_rounded),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedDate != null
                                  ? DateFormat(
                                      'dd MMM yyyy',
                                    ).format(_selectedDate!)
                                  : 'Select date (optional)',
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? CampusStyle.ink
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Description Field
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description / Notes',
                            hintText: 'Optional instructions or exam notes',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 18),
                      label: Text(_isLoading ? 'Creating...' : 'Create Exam'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
