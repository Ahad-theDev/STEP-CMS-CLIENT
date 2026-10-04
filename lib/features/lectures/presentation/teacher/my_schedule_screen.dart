import 'package:cms/features/attendance/presentation/screens/teacher/mark_lecture_attendance_screen.dart';
import 'package:cms/features/lectures/application/my_schedule_controller.dart';
import 'package:cms/features/lectures/data/models/my_schedule_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';

const List<String> _weekDays = [
  'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
];

class MyScheduleScreen extends ConsumerStatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  ConsumerState<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends ConsumerState<MyScheduleScreen> {
  // null day + null date = full week, no filter (per backend docs)
  String? _selectedDay;
  bool _todayMode = true;
  DateTime? _customDate;
  late final DateTime _todayDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDate = DateTime(now.year, now.month, now.day); // stable for the life of this screen
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _selectToday() {
    setState(() {
      _todayMode = true;
      _selectedDay = null;
      _customDate = null;
    });
  }

  void _selectFullWeek() {
    setState(() {
      _todayMode = false;
      _selectedDay = null;
      _customDate = null;
    });
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? _todayDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _todayMode = false;
        _selectedDay = null;
        _customDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  DateTime get _effectiveDate {
    if (_customDate != null) return _customDate!;
    if (_todayMode) return _todayDate;
    if (_selectedDay != null) {
      final mondayOffset = _todayDate.weekday == DateTime.sunday
          ? -1
          : (_todayDate.weekday - DateTime.monday);
      final monday = _todayDate.subtract(Duration(days: mondayOffset));
      final dayIndex = _weekDays.indexOf(_selectedDay!);
      if (dayIndex >= 0) {
        return monday.add(Duration(days: dayIndex));
      }
    }
    return _todayDate;
  }

  Future<void> _openMarkAttendance(MyScheduleLecture lecture) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MarkLectureAttendanceScreen(
          lectureId: lecture.id,
          initialDate: _effectiveDate,
        ),
      ),
    );
    if (result == true) {
      ref.invalidate(myScheduleControllerProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFilterDate = _todayMode ? _todayDate : _customDate;

    final scheduleAsync = ref.watch(myScheduleControllerProvider(
      day: _selectedDay,
      date: effectiveFilterDate,
    ));
    final subjectsAsync = ref.watch(subjectsListControllerProvider);
    final subjectNameById = {
      for (final s in subjectsAsync.valueOrNull ?? []) s.id: s.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Pick Date',
            onPressed: _pickCustomDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Today'),
                      selected: _todayMode,
                      onSelected: (_) => _selectToday(),
                    ),
                    ChoiceChip(
                      label: const Text('Full Week'),
                      selected: !_todayMode && _selectedDay == null && _customDate == null,
                      onSelected: (_) => _selectFullWeek(),
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.event, size: 16),
                      label: Text(_customDate != null ? _fmt(_customDate!) : 'Pick Date'),
                      selected: _customDate != null,
                      onSelected: (_) => _pickCustomDate(),
                    ),
                    ..._weekDays.map((d) => ChoiceChip(
                          label: Text(d[0].toUpperCase() + d.substring(1)),
                          selected: !_todayMode && _selectedDay == d && _customDate == null,
                          onSelected: (_) => setState(() {
                            _todayMode = false;
                            _customDate = null;
                            _selectedDay = d;
                          }),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _customDate != null
                      ? 'Showing timetable for ${_fmt(_customDate!)}. Tap any lecture to mark attendance.'
                      : _todayMode
                          ? 'Showing lectures scheduled for today. Tap any lecture to mark attendance.'
                          : 'Weekly timetable template. Tap any lecture to mark attendance.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: scheduleAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Failed to load schedule: ${friendlyErrorMessage(e)}')),
              data: (schedule) {
                if (schedule.lectures.isEmpty) {
                  return const Center(child: Text('No lectures scheduled'));
                }
                final sorted = [...schedule.lectures]
                  ..sort((a, b) {
                    final dayCompare = _weekDays.indexOf(a.dayOfWeek).compareTo(_weekDays.indexOf(b.dayOfWeek));
                    if (dayCompare != 0) return dayCompare;
                    return a.startTime.compareTo(b.startTime);
                  });

                return ListView.separated(
                  itemCount: sorted.length,
                  separatorBuilder: (_, unusedParam) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lec = sorted[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        subjectNameById[lec.subjectId] ?? 'Subject ${lec.subjectId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            '${lec.dayOfWeek[0].toUpperCase()}${lec.dayOfWeek.substring(1)} • '
                            '${TimeOfDayUtils.displayLabel(lec.startTime)} - ${TimeOfDayUtils.displayLabel(lec.endTime)} • '
                            'Room ${lec.roomNumber}',
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.how_to_reg_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to mark attendance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${lec.studentCount} students',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        ],
                      ),
                      onTap: () => _openMarkAttendance(lec),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}