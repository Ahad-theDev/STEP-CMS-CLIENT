import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/update_staff_controller.dart';
import '../../data/models/staff_member.dart';
import '../../data/models/staff_update_request.dart';

class UpdateStaffScreen extends ConsumerStatefulWidget {
  final StaffMember staff;
  const UpdateStaffScreen({super.key, required this.staff});

  @override
  ConsumerState<UpdateStaffScreen> createState() => _UpdateStaffScreenState();
}

class _UpdateStaffScreenState extends ConsumerState<UpdateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _designationController;
  DateTime? _joinDate;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.staff.fullName);
    _designationController = TextEditingController(text: widget.staff.designation ?? '');
    _joinDate = widget.staff.joinDate;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _joinDate = picked);
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

    final request = StaffUpdateRequest(
      fullName: _fullNameController.text.trim(),
      designation: _designationController.text.trim(),
      joinDate: _joinDate,
    );

    final updated =
        await ref.read(updateStaffControllerProvider.notifier).updateStaff(widget.staff.id, request);
    if (!mounted || updated == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${updated.fullName} updated')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateStaffControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Update Staff')),
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
                decoration: const InputDecoration(labelText: 'Designation'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickJoinDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Join Date'),
                  child: Text(
                    _joinDate == null
                        ? 'Tap to select'
                        : '${_joinDate!.year}-${_joinDate!.month.toString().padLeft(2, '0')}-${_joinDate!.day.toString().padLeft(2, '0')}',
                  ),
                ),
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