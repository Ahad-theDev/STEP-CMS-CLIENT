import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/add_staff_controller.dart';
import '../../data/models/staff_create_request.dart';

class AddStaffScreen extends ConsumerStatefulWidget {
  const AddStaffScreen({super.key});

  @override
  ConsumerState<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends ConsumerState<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _designationController = TextEditingController();
  final _userIdController = TextEditingController(); // optional — links to an existing login account
  DateTime? _joinDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _designationController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _joinDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = StaffCreateRequest(
      userId: _userIdController.text.trim().isEmpty ? null : _userIdController.text.trim(),
      fullName: _fullNameController.text.trim(),
      designation: _designationController.text.trim(),
      joinDate: _joinDate,
    );

    final staff = await ref.read(addStaffControllerProvider.notifier).createStaff(request);
    if (!mounted || staff == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${staff.fullName} added')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addStaffControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Staff')),
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
                controller: _designationController,
                decoration: const InputDecoration(labelText: 'Designation (optional)'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickJoinDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Join Date (optional)'),
                  child: Text(
                    _joinDate == null
                        ? 'Tap to select'
                        : '${_joinDate!.year}-${_joinDate!.month.toString().padLeft(2, '0')}-${_joinDate!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'Linked User ID (optional)',
                  helperText: 'Only needed if this staff member should also have a login account',
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
                    : const Text('Add Staff'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}