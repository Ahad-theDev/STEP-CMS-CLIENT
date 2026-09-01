import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import '../../application/create_override_controller.dart';
import '../../data/models/lecture.dart';
import '../../data/models/lecture_override_request.dart';

class CreateOverrideScreen extends ConsumerStatefulWidget {
  final Lecture lecture;
  const CreateOverrideScreen({super.key, required this.lecture});

  @override
  ConsumerState<CreateOverrideScreen> createState() => _CreateOverrideScreenState();
}

class _CreateOverrideScreenState extends ConsumerState<CreateOverrideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _roomController = TextEditingController();
  DateTime? _date;
  LectureOverrideType _overrideType = LectureOverrideType.cancelled;
  Teacher? _substituteTeacher;
  TimeOfDay? _newStartTime;
  TimeOfDay? _newEndTime;

  @override
  void dispose() {
    _reasonController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _newStartTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _newEndTime = picked);
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
    }
    return error.toString();
  }

  Future<void> _submit() async {
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a date')));
      return;
    }
    if (_overrideType == LectureOverrideType.substituteTeacher && _substituteTeacher == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a substitute teacher')));
      return;
    }
    if (_overrideType == LectureOverrideType.rescheduled &&
        _newStartTime == null &&
        _newEndTime == null &&
        _roomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provide a new time and/or room for the reschedule')));
      return;
    }

    final request = LectureOverrideRequest(
      date: _date!,
      overrideType: _overrideType,
      teacherId: _overrideType == LectureOverrideType.substituteTeacher
          ? _substituteTeacher!.id
          : null,
      startTime: _overrideType == LectureOverrideType.rescheduled ? _newStartTime : null,
      endTime: _overrideType == LectureOverrideType.rescheduled ? _newEndTime : null,
      roomNumber: _overrideType == LectureOverrideType.rescheduled
          ? _roomController.text.trim()
          : null,
      reason: _reasonController.text.trim(),
    );

    final result = await ref
        .read(createOverrideControllerProvider.notifier)
        .createOverride(widget.lecture.id, request);
    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Override created')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createOverrideControllerProvider);
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Override')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                '${widget.lecture.dayOfWeek[0].toUpperCase()}${widget.lecture.dayOfWeek.substring(1)} • '
                'Room ${widget.lecture.roomNumber}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(_date == null
                      ? 'Tap to select'
                      : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}'),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LectureOverrideType>(
                initialValue: _overrideType,
                decoration: const InputDecoration(labelText: 'Override Type'),
                items: LectureOverrideType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (v) => setState(() => _overrideType = v ?? _overrideType),
              ),
              const SizedBox(height: 12),
              if (_overrideType == LectureOverrideType.substituteTeacher)
                teachersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) =>
                      Text('Failed to load teachers: $e', style: const TextStyle(color: Colors.red)),
                  data: (teachers) => DropdownButtonFormField<Teacher>(
                    initialValue: _substituteTeacher,
                    decoration: const InputDecoration(labelText: 'Substitute Teacher'),
                    items: teachers
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.fullName)))
                        .toList(),
                    onChanged: (v) => setState(() => _substituteTeacher = v),
                  ),
                ),
              if (_overrideType == LectureOverrideType.rescheduled) ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'New Start (optional)'),
                          child: Text(_newStartTime?.format(context) ?? 'Unchanged'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'New End (optional)'),
                          child: Text(_newEndTime?.format(context) ?? 'Unchanged'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(labelText: 'New Room (optional)'),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Reason (optional)'),
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
                    : const Text('Create Override'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}