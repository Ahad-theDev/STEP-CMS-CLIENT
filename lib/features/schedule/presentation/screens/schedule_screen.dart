import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/subjects/data/models/subject.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/schedule_preview_controller.dart';
import '../../application/publish_controller.dart';
import '../../data/models/resolved_lecture.dart';
import 'bulk_shift_screen.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  
  
  
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  
  
  
  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Color _statusColor(String status) {
    switch (status) {
      case 'substitute':
        return Colors.amber.shade100;
      case 'rescheduled':
        return Colors.blue.shade50;
      case 'cancelled':
        return Colors.red.shade50;
      default:
        return Colors.transparent;
    }
  }

  Future<void> _openBulkShift() async {
    final shifted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => BulkShiftScreen(date: _selectedDate)),
    );
    if (shifted == true) {
      ref.invalidate(schedulePreviewControllerProvider(date: _selectedDate));
    }
  }

  Future<void> _publish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish & Notify'),
        content: Text(
          'Notify all affected teachers about ${_formatDate(_selectedDate)}\'s schedule? '
          'Teachers already notified for this date will be skipped.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Publish')),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await ref.read(publishControllerProvider.notifier).publish(_selectedDate);
    if (!mounted) return;

    if (result == null) {
      final error = ref.read(publishControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Publish failed: ${error != null ? friendlyErrorMessage(error) : 'Unknown error'}'),
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Notified ${result.notified.length} teacher(s)'
        '${result.skippedDuplicate.isNotEmpty ? ', skipped ${result.skippedDuplicate.length} already notified' : ''}',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final previewAsync = ref.watch(
      schedulePreviewControllerProvider(date: _selectedDate),
    );
    final publishState = ref.watch(publishControllerProvider);
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final subjectsAsync = ref.watch(subjectsListControllerProvider);

    final Map<String, String> classNameById = {
      for (final c in classesAsync.valueOrNull ?? <SchoolClass>[])
        c.id: '${c.name}-${c.section}',
    };
    final Map<String, String> teacherNameById = {
      for (final t in teachersAsync.valueOrNull ?? <Teacher>[])
        t.id: t.fullName,
    };
    final Map<String, String> subjectNameById = {
      for (final s in subjectsAsync.valueOrNull ?? <Subject>[]) s.id: s.name,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_formatDate(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Bulk Shift button
                    OutlinedButton.icon(
                      onPressed: _openBulkShift,
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                      label: const Text('Bulk Shift'),
                    ),
                    const SizedBox(width: 8),
                    // Publish button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: publishState.isLoading ? null : _publish,
                        icon: publishState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.campaign_rounded, size: 18),
                        label: const Text('Publish'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: previewAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Failed to load schedule: ${friendlyErrorMessage(e)}')),
              data: (preview) {
                if (preview.isHoliday) {
                  return const Center(
                    child: Text(
                      'Holiday — no lectures scheduled',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                if (preview.lectures.isEmpty) {
                  return const Center(
                    child: Text('No lectures scheduled for this date'),
                  );
                }

                final sorted = [...preview.lectures]
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));

                // Build timetable grid
                return _buildTimetableGrid(
                  sorted,
                  classNameById,
                  teacherNameById,
                  subjectNameById,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableGrid(
    List<ResolvedLecture> lectures,
    Map<String, String> classNameById,
    Map<String, String> teacherNameById,
    Map<String, String> subjectNameById,
  ) {
    // Extract unique time slots and classes
    final timeSlots =
        lectures
            .map(
              (l) =>
                  '${TimeOfDayUtils.displayLabel(l.startTime)} - ${TimeOfDayUtils.displayLabel(l.endTime)}',
            )
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

    final classIds = lectures.map((l) => l.classId).toSet().toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable(
            columnSpacing: 16,
            dataRowMinHeight: 96,
            dataRowMaxHeight: 96,
            headingRowColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            columns: [
              const DataColumn(
                label: Text(
                  'Class',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...timeSlots.map(
                (slot) => DataColumn(
                  label: Text(
                    slot,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            rows: classIds.map((classId) {
              final classLectures = lectures
                  .where((l) => l.classId == classId)
                  .toList();
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      classNameById[classId] ?? classId,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  ...timeSlots.map((slot) {
                    ResolvedLecture? lec;
                    for (final l in classLectures) {
                      if ('${TimeOfDayUtils.displayLabel(l.startTime)} - ${TimeOfDayUtils.displayLabel(l.endTime)}' ==
                          slot) {
                        lec = l;
                        break;
                      }
                    }
                    if (lec == null) return const DataCell(Text('-'));
                    return DataCell(
                      Container(
                        width: 110,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _statusColor(lec.status),
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              subjectNameById[lec.subjectId] ?? lec.subjectId,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Room: ${lec.roomNumber}',
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              teacherNameById[lec.teacherId] ?? lec.teacherId,
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              lec.status[0].toUpperCase() + lec.status.substring(1),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: lec.status == 'cancelled' ? Colors.red : Colors.black,
                                decoration: lec.status == 'cancelled' ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
