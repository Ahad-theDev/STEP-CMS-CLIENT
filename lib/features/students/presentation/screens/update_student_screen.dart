import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/update_student_controller.dart';
import '../../data/models/student.dart';
import '../../data/models/student_update_request.dart';

class UpdateStudentScreen extends ConsumerStatefulWidget {
  final Student student;
  const UpdateStudentScreen({super.key, required this.student});

  @override
  ConsumerState<UpdateStudentScreen> createState() => _UpdateStudentScreenState();
}

class _UpdateStudentScreenState extends ConsumerState<UpdateStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _rollNumberController;
  late final TextEditingController _guardianNameController;
  late final TextEditingController _guardianPhoneController;
  late final TextEditingController _monthlyFeeController;
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _fullNameController = TextEditingController(text: s.fullName);
    _rollNumberController = TextEditingController(text: s.rollNumber);
    _guardianNameController = TextEditingController(text: s.guardianName ?? '');
    _guardianPhoneController = TextEditingController(text: s.guardianPhone ?? '');
    _monthlyFeeController = TextEditingController(text: s.monthlyFee.toStringAsFixed(0));
    _discountController = TextEditingController(text: s.discount.toStringAsFixed(0));
  }

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

  String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
    }
    return error.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = StudentUpdateRequest(
      fullName: _fullNameController.text.trim(),
      rollNumber: _rollNumberController.text.trim(),
      guardianName: _guardianNameController.text.trim(),
      guardianPhone: _guardianPhoneController.text.trim(),
      monthlyFee: double.tryParse(_monthlyFeeController.text.trim()),
      discount: double.tryParse(_discountController.text.trim()),
    );

    final updated = await ref
        .read(updateStudentControllerProvider.notifier)
        .updateStudent(widget.student.id, request);
    if (!mounted || updated == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${updated.fullName} updated')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateStudentControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Update Student')),
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
              TextFormField(
                controller: _guardianNameController,
                decoration: const InputDecoration(labelText: 'Guardian Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _guardianPhoneController,
                decoration: const InputDecoration(labelText: 'Guardian Phone'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _monthlyFeeController,
                decoration: const InputDecoration(labelText: 'Monthly Fee'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Discount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Text(
                'To move this student to a different class, use Change Enrollment instead — '
                'it keeps enrollment history consistent.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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