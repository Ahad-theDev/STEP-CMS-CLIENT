import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/students/presentation/screens/select_student_screen.dart';
import 'package:cms/features/students/data/models/student.dart';
import '../../application/generate_student_fee_controller.dart';
import '../../data/models/fee_generate_request.dart';

class GenerateStudentFeeScreen extends ConsumerStatefulWidget {
  const GenerateStudentFeeScreen({super.key});

  @override
  ConsumerState<GenerateStudentFeeScreen> createState() => _GenerateStudentFeeScreenState();
}

class _GenerateStudentFeeScreenState extends ConsumerState<GenerateStudentFeeScreen> {
  Student? _selectedStudent;
  int _month = DateTime.now().month;
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: DateTime.now().year.toString());
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickStudent() async {
    final selected = await Navigator.of(context).push<Student>(
      MaterialPageRoute(builder: (_) => const SelectStudentScreen(title: 'Select Student')),
    );
    if (selected != null) setState(() => _selectedStudent = selected);
  }

  Future<void> _submit() async {
    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a student')));
      return;
    }
    final year = int.tryParse(_yearController.text.trim());
    if (year == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid year')));
      return;
    }

    final request = SingleGenerateFeeRequest(month: _month, year: year);
    final result = await ref
        .read(generateStudentFeeControllerProvider.notifier)
        .generate(_selectedStudent!.id, request);
    if (!mounted || result == null) return;

    if (result.success > 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fee record generated')));
      Navigator.of(context).pop(true);
    } else {
      final reason = result.errors.isNotEmpty ? result.errors.first.reason : 'Already exists';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Not generated: $reason')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generateStudentFeeControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Fee for Student')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            InkWell(
              onTap: _pickStudent,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Student'),
                child: Text(_selectedStudent == null ? 'Tap to select' : _selectedStudent!.fullName),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _month,
              decoration: const InputDecoration(labelText: 'Month'),
              items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text([
                        'January', 'February', 'March', 'April', 'May', 'June',
                        'July', 'August', 'September', 'October', 'November', 'December'
                      ][i]))),
              onChanged: (v) => setState(() => _month = v ?? _month),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
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
                  : const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}