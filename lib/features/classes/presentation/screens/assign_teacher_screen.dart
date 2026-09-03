import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import '../../application/assign_teacher_controller.dart';
import '../../data/models/assign_teacher_request.dart';
import '../../data/models/school_class.dart';

class AssignTeacherScreen extends ConsumerStatefulWidget {
  final SchoolClass schoolClass;
  const AssignTeacherScreen({super.key, required this.schoolClass});

  @override
  ConsumerState<AssignTeacherScreen> createState() => _AssignTeacherScreenState();
}

class _AssignTeacherScreenState extends ConsumerState<AssignTeacherScreen> {
  Teacher? _selectedTeacher;

  Future<void> _submit() async {
    if (_selectedTeacher == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a teacher')));
      return;
    }

    final request = AssignTeacherRequest(teacherId: _selectedTeacher!.id);
    final success = await ref
        .read(assignTeacherControllerProvider.notifier)
        .assignTeacher(widget.schoolClass.id, request);
    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teacher assigned')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assignTeacherControllerProvider);
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Teacher')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text('${widget.schoolClass.name} - ${widget.schoolClass.section}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            teachersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Text('Failed to load teachers: ${friendlyErrorMessage(e)}', style: const TextStyle(color: Colors.red)),
              data: (teachers) => DropdownButtonFormField<Teacher>(
                // ignore: deprecated_member_use
                value: _selectedTeacher,
                decoration: const InputDecoration(labelText: 'Select Teacher'),
                items: teachers
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.fullName)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTeacher = v),
              ),
            ),
            const SizedBox(height: 24),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Failed: ${friendlyErrorMessage(state.error!)}',
                    style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Assign Teacher'),
            ),
          ],
        ),
      ),
    );
  }
}