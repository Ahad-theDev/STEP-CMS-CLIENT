import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';
import 'package:cms/features/subjects/data/models/subject.dart';
import '../../application/update_teacher_controller.dart';
import '../../data/models/teacher.dart';
import '../../data/models/teacher_update_request.dart';

class UpdateTeacherScreen extends ConsumerStatefulWidget {
  final Teacher teacher;
  const UpdateTeacherScreen({super.key, required this.teacher});

  @override
  ConsumerState<UpdateTeacherScreen> createState() => _UpdateTeacherScreenState();
}

class _UpdateTeacherScreenState extends ConsumerState<UpdateTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _departmentController;
  late final TextEditingController _qualificationController;
  DateTime? _hireDate;
  Subject? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _departmentController = TextEditingController(text: widget.teacher.department ?? '');
    _qualificationController = TextEditingController(text: widget.teacher.qualification ?? '');
    _hireDate = widget.teacher.hireDate;
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Subject? _findById(List<Subject> subjects, String? id) {
    if (id == null) return null;
    for (final s in subjects) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> _pickHireDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _hireDate = picked);
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
    }
    return error.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = TeacherUpdateRequest(
      department: _departmentController.text.trim(),
      hireDate: _hireDate,
      qualification: _qualificationController.text.trim(),
      subjectSpecializationId: _selectedSubject?.id,
    );

    final updated = await ref
        .read(updateTeacherControllerProvider.notifier)
        .updateTeacher(widget.teacher.id, request);
    if (!mounted || updated == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${updated.fullName} updated')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateTeacherControllerProvider);
    final subjectsAsync = ref.watch(subjectsListControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Update Teacher')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(widget.teacher.fullName, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickHireDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Hire Date'),
                  child: Text(
                    _hireDate == null
                        ? 'Tap to select'
                        : '${_hireDate!.year}-${_hireDate!.month.toString().padLeft(2, '0')}-${_hireDate!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(labelText: 'Qualification'),
              ),
              const SizedBox(height: 12),
              subjectsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) =>
                    Text('Failed to load subjects: $e', style: const TextStyle(color: Colors.red)),
                data: (subjects) {
                  _selectedSubject ??=
                      _findById(subjects, widget.teacher.subjectSpecializationId);
                  return DropdownButtonFormField<Subject?>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(labelText: 'Subject Specialization (optional)'),
                    items: [
                      const DropdownMenuItem<Subject?>(value: null, child: Text('None')),
                      ...subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))),
                    ],
                    onChanged: (v) => setState(() => _selectedSubject = v),
                  );
                },
              ),
              const SizedBox(height: 24),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Failed: ${_friendlyError(state.error!)}',
                      style: const TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}