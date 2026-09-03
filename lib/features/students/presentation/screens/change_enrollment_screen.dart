import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/change_enrollment_controller.dart';
import '../../data/models/enrollment_change_request.dart';
import '../../data/models/student.dart';

class ChangeEnrollmentScreen extends ConsumerStatefulWidget {
  final Student student;
  const ChangeEnrollmentScreen({super.key, required this.student});

  @override
  ConsumerState<ChangeEnrollmentScreen> createState() => _ChangeEnrollmentScreenState();
}

class _ChangeEnrollmentScreenState extends ConsumerState<ChangeEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  SchoolClass? _selectedClass;
  late final TextEditingController _academicYearController;

  @override
  void initState() {
    super.initState();
    final year = DateTime.now().year;
    _academicYearController = TextEditingController(text: '$year-${year + 1}');
  }

  @override
  void dispose() {
    _academicYearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select the new class')));
      return;
    }

    final request = EnrollmentChangeRequest(
      newClassId: _selectedClass!.id,
      academicYear: _academicYearController.text.trim(),
    );

    final success = await ref
        .read(changeEnrollmentControllerProvider.notifier)
        .changeEnrollment(widget.student.id, request);
    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrollment updated')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changeEnrollmentControllerProvider);
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Change Enrollment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Student: ${widget.student.fullName} (Roll #${widget.student.rollNumber})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              classesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) =>
                    Text('Failed to load classes: ${friendlyErrorMessage(e)}', style: const TextStyle(color: Colors.red)),
                data: (classes) {
                  final options = classes.where((c) => c.id != widget.student.classId).toList();
                  return DropdownButtonFormField<SchoolClass>(
                    initialValue: _selectedClass,
                    decoration: const InputDecoration(labelText: 'New Class'),
                    items: options
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text('${c.name} - ${c.section} (${c.academicYear})'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedClass = v),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _academicYearController,
                decoration: const InputDecoration(labelText: 'Academic Year'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                    : const Text('Change Enrollment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}