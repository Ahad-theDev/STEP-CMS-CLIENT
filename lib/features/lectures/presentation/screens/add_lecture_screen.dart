import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';
import 'package:cms/features/subjects/data/models/subject.dart';
import '../../application/add_lecture_controller.dart';
import '../../data/models/lecture_create_request.dart';
import '../widgets/lecture_search_section.dart' show weekDays;

class AddLectureScreen extends ConsumerStatefulWidget {
  const AddLectureScreen({super.key});

  @override
  ConsumerState<AddLectureScreen> createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends ConsumerState<AddLectureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomController = TextEditingController();
  SchoolClass? _selectedClass;
  Teacher? _selectedTeacher;
  Subject? _selectedSubject;
  String? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _endTime = picked);
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
    if (_selectedClass == null ||
        _selectedTeacher == null ||
        _selectedSubject == null ||
        _selectedDay == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final request = LectureCreateRequest(
      classId: _selectedClass!.id,
      teacherId: _selectedTeacher!.id,
      subjectId: _selectedSubject!.id,
      dayOfWeek: _selectedDay!,
      roomNumber: _roomController.text.trim(),
      startTime: _startTime!,
      endTime: _endTime!,
    );

    final lecture = await ref.read(addLectureControllerProvider.notifier).createLecture(request);
    if (!mounted || lecture == null) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lecture created')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addLectureControllerProvider);
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final subjectsAsync = ref.watch(subjectsListControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Lecture')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              classesAsync.when(
                loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator()),
                error: (e, _) =>
                    Text('Failed to load classes: $e', style: const TextStyle(color: Colors.red)),
                data: (classes) => DropdownButtonFormField<SchoolClass>(
                  initialValue: _selectedClass,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: classes
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text('${c.name} - ${c.section}')))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedClass = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              teachersAsync.when(
                loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator()),
                error: (e, _) =>
                    Text('Failed to load teachers: $e', style: const TextStyle(color: Colors.red)),
                data: (teachers) => DropdownButtonFormField<Teacher>(
                  initialValue: _selectedTeacher,
                  decoration: const InputDecoration(labelText: 'Teacher'),
                  items: teachers
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.fullName)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTeacher = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              subjectsAsync.when(
                loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator()),
                error: (e, _) =>
                    Text('Failed to load subjects: $e', style: const TextStyle(color: Colors.red)),
                data: (subjects) => DropdownButtonFormField<Subject>(
                  initialValue: _selectedSubject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: subjects
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSubject = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedDay,
                decoration: const InputDecoration(labelText: 'Day of Week'),
                items: weekDays
                    .map((d) => DropdownMenuItem(
                        value: d, child: Text(d[0].toUpperCase() + d.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDay = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Room Number'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start Time'),
                        child: Text(_startTime == null ? 'Tap to select' : _startTime!.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'End Time'),
                        child: Text(_endTime == null ? 'Tap to select' : _endTime!.format(context)),
                      ),
                    ),
                  ),
                ],
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
                    : const Text('Create Lecture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}