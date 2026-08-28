import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import '../../application/add_class_controller.dart';
import '../../data/models/class_create_request.dart';

class AddClassScreen extends ConsumerStatefulWidget {
  const AddClassScreen({super.key});

  @override
  ConsumerState<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends ConsumerState<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sectionController = TextEditingController();
  late final TextEditingController _academicYearController;
  Teacher? _selectedTeacher;

  @override
  void initState() {
    super.initState();
    final year = DateTime.now().year;
    _academicYearController = TextEditingController(text: '$year-${year + 1}');
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

    final request = ClassCreateRequest(
      name: _nameController.text.trim(),
      section: _sectionController.text.trim(),
      academicYear: _academicYearController.text.trim(),
      classTeacherId: _selectedTeacher?.id,
    );

    final cls = await ref.read(addClassControllerProvider.notifier).createClass(request);
    if (!mounted || cls == null) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${cls.name} - ${cls.section} created')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addClassControllerProvider);
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Class')),
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
              teachersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) =>
                    Text('Failed to load teachers: $e', style: const TextStyle(color: Colors.red)),
                data: (teachers) => DropdownButtonFormField<Teacher?>(
                  // ignore: deprecated_member_use
                  value: _selectedTeacher,
                  decoration: const InputDecoration(labelText: 'Class Teacher (optional)'),
                  items: [
                    const DropdownMenuItem<Teacher?>(value: null, child: Text('None')),
                    ...teachers.map((t) => DropdownMenuItem(value: t, child: Text(t.fullName))),
                  ],
                  onChanged: (v) => setState(() => _selectedTeacher = v),
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
                    : const Text('Create Class'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}