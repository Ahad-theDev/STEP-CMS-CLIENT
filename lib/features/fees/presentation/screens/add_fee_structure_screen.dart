import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/add_fee_structure_controller.dart';
import '../../data/models/fee_structure_create_request.dart';

class AddFeeStructureScreen extends ConsumerStatefulWidget {
  const AddFeeStructureScreen({super.key});

  @override
  ConsumerState<AddFeeStructureScreen> createState() => _AddFeeStructureScreenState();
}

class _AddFeeStructureScreenState extends ConsumerState<AddFeeStructureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _yearController = TextEditingController();
  SchoolClass? _selectedClass;

  @override
  void dispose() {
    _amountController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onClassChanged(SchoolClass? cls) {
    setState(() {
      _selectedClass = cls;
      if (cls != null && _yearController.text.isEmpty) {
        _yearController.text = cls.academicYear;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a class')));
      return;
    }

    final request = FeeStructureCreateRequest(
      classId: _selectedClass!.id,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      academicYear: _yearController.text.trim(),
    );

    final result = await ref.read(addFeeStructureControllerProvider.notifier).createFeeStructure(request);
    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fee structure created')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addFeeStructureControllerProvider);
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Fee Structure')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              classesAsync.when(
                loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator()),
                error: (e, _) =>
                    Text('Failed to load classes: ${friendlyErrorMessage(e)}',
                        style: const TextStyle(color: Colors.red)),
                data: (classes) => DropdownButtonFormField<SchoolClass>(
                  initialValue: _selectedClass,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: classes
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text('${c.name} - ${c.section}')))
                      .toList(),
                  onChanged: _onClassChanged,
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
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
                    : const Text('Create Fee Structure'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}