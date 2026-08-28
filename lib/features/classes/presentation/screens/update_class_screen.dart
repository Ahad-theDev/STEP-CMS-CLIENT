import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/update_class_controller.dart';
import '../../data/models/class_update_request.dart';
import '../../data/models/school_class.dart';

class UpdateClassScreen extends ConsumerStatefulWidget {
  final SchoolClass schoolClass;
  const UpdateClassScreen({super.key, required this.schoolClass});

  @override
  ConsumerState<UpdateClassScreen> createState() => _UpdateClassScreenState();
}

class _UpdateClassScreenState extends ConsumerState<UpdateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sectionController;
  late final TextEditingController _academicYearController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.schoolClass.name);
    _sectionController = TextEditingController(text: widget.schoolClass.section);
    _academicYearController = TextEditingController(text: widget.schoolClass.academicYear);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    _academicYearController.dispose();
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

    final request = ClassUpdateRequest(
      name: _nameController.text.trim(),
      section: _sectionController.text.trim(),
      academicYear: _academicYearController.text.trim(),
    );

    final updated = await ref
        .read(updateClassControllerProvider.notifier)
        .updateClass(widget.schoolClass.id, request);
    if (!mounted || updated == null) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${updated.name} - ${updated.section} updated')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateClassControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Update Class')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Class Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sectionController,
                decoration: const InputDecoration(labelText: 'Section'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _academicYearController,
                decoration: const InputDecoration(labelText: 'Academic Year'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Text(
                'To assign or change this class\'s teacher, use Assign Teacher instead.',
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