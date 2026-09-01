import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';
import 'package:cms/features/subjects/data/models/subject.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';
import '../../application/update_lecture_controller.dart';
import '../../data/models/lecture.dart';
import '../../data/models/lecture_update_request.dart';
import '../widgets/lecture_search_section.dart' show weekDays;

class UpdateLectureScreen extends ConsumerStatefulWidget {
  final Lecture lecture;
  const UpdateLectureScreen({super.key, required this.lecture});

  @override
  ConsumerState<UpdateLectureScreen> createState() => _UpdateLectureScreenState();
}

class _UpdateLectureScreenState extends ConsumerState<UpdateLectureScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _roomController;
  Teacher? _selectedTeacher;
  Subject? _selectedSubject;
  late String _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _roomController = TextEditingController(text: widget.lecture.roomNumber);
    _selectedDay = widget.lecture.dayOfWeek;
    _startTime = TimeOfDayUtils.parse(widget.lecture.startTime);
    _endTime = TimeOfDayUtils.parse(widget.lecture.endTime);
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  Teacher? _findTeacher(List<Teacher> teachers) {
    for (final t in teachers) {
      if (t.id == widget.lecture.teacherId) return t;
    }
    return null;
  }

  Subject? _findSubject(List<Subject> subjects) {
    for (final s in subjects) {
      if (s.id == widget.lecture.subjectId) return s;
    }
    return null;
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime);
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

    final request = LectureUpdateRequest(
      teacherId: _selectedTeacher?.id,
      subjectId: _selectedSubject?.id,
      dayOfWeek: _selectedDay,
      roomNumber: _roomController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
    );

    final updated = await ref
        .read(updateLectureControllerProvider.notifier)
        .updateLecture(widget.lecture.id, request);
    if (!mounted || updated == null) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lecture updated')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateLectureControllerProvider);
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final subjectsAsync = ref.watch(subjectsListControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Update Lecture')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              teachersAsync.when(
                loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator()),
                error: (e, _) =>
                    Text('Failed to load teachers: $e', style: const TextStyle(color: Colors.red)),
                data: (teachers) {
                  _selectedTeacher ??= _findTeacher(teachers);
                  return DropdownButtonFormField<Teacher>(
                    value: _selectedTeacher,
                    decoration: const InputDecoration(labelText: 'Teacher'),
                    items: teachers
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.fullName)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTeacher = v),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              subjectsAsync.when(
                loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator()),
                error: (e, _) =>
                    Text('Failed to load subjects: $e', style: const TextStyle(color: Colors.red)),
                data: (subjects) {
                  _selectedSubject ??= _findSubject(subjects);
                  return DropdownButtonFormField<Subject>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: subjects
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSubject = v),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: const InputDecoration(labelText: 'Day of Week'),
                items: weekDays
                    .map((d) => DropdownMenuItem(
                        value: d, child: Text(d[0].toUpperCase() + d.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDay = v ?? _selectedDay),
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
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'End Time'),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This edits the permanent weekly slot. For a one-off change on a specific '
                'date, use Create Override instead.',
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