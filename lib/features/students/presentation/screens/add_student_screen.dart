import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/add_student_controller.dart';
import '../../data/models/student_create_request.dart';
import '../../../classes/application/classes_list_controller.dart';
import '../../../classes/data/models/school_class.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _monthlyFeeController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  DateTime? _admissionDate;
  SchoolClass? _selectedClass;

  @override
  void dispose() {
    _fullNameController.dispose();
    _rollNumberController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _monthlyFeeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickAdmissionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _admissionDate = picked);
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
    if (_admissionDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Admission date is required')));
      return;
    }
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a class')));
      return;
    }

    final request = StudentCreateRequest(
      fullName: _fullNameController.text.trim(),
      rollNumber: _rollNumberController.text.trim(),
      classId: _selectedClass!.id,
      guardianName: _guardianNameController.text.trim(),
      guardianPhone: _guardianPhoneController.text.trim(),
      admissionDate: _admissionDate!,
      monthlyFee: double.tryParse(_monthlyFeeController.text.trim()) ?? 0,
      discount: double.tryParse(_discountController.text.trim()) ?? 0,
    );

    final student = await ref.read(addStudentControllerProvider.notifier).createStudent(request);
    if (!mounted || student == null) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${student.fullName} added')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addStudentControllerProvider);
    final classesAsync = ref.watch(classesListControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rollNumberController,
                decoration: const InputDecoration(labelText: 'Roll Number'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              classesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Row(
                  children: [
                    Expanded(child: Text('Failed to load classes: $e', style: const TextStyle(color: Colors.red))),
                    TextButton(
                      onPressed: () => ref.read(classesListControllerProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
                data: (classes) {
                  if (classes.isEmpty) {
                    return const Text('No classes found — create one first.',
                        style: TextStyle(color: Colors.grey));
                  }
                  return DropdownButtonFormField<SchoolClass>(
                    value: _selectedClass,
                    decoration: const InputDecoration(labelText: 'Class'),
                    items: classes
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text('${c.name} - ${c.section} (${c.academicYear})'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedClass = v),
                    validator: (v) => v == null ? 'Please select a class' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _guardianNameController,
                decoration: const InputDecoration(labelText: 'Guardian Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _guardianPhoneController,
                decoration: const InputDecoration(labelText: 'Guardian Phone'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickAdmissionDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Admission Date'),
                  child: Text(
                    _admissionDate == null
                        ? 'Tap to select'
                        : '${_admissionDate!.year}-${_admissionDate!.month.toString().padLeft(2, '0')}-${_admissionDate!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _monthlyFeeController,
                decoration: const InputDecoration(labelText: 'Monthly Fee'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Discount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Failed: ${_friendlyError(state.error!)}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}