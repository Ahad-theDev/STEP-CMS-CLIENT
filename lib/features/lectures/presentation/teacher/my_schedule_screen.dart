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
  late final DateTime _todayDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDate = DateTime(now.year, now.month, now.day); // stable for the life of this screen
  }

  void _selectToday() {
    setState(() {
      _todayMode = true;
      _selectedDay = null;
    });
  }

  void _selectFullWeek() {
    setState(() {
      _todayMode = false;
      _selectedDay = null;
    });
  }

  Future<void> _openMarkAttendance(MyScheduleLecture lecture) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MarkLectureAttendanceScreen(lectureId: lecture.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(myScheduleControllerProvider(
      day: _selectedDay,
      date: _todayMode ? _todayDate : null,
    ));
    final subjectsAsync = ref.watch(subjectsListControllerProvider);
    final subjectNameById = {
      for (final s in subjectsAsync.valueOrNull ?? []) s.id: s.name,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('My Schedule')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(label: const Text('Today'), selected: _todayMode, onSelected: (_) => _selectToday()),
                    ChoiceChip(
                        label: const Text('Full Week'),
                        selected: !_todayMode && _selectedDay == null,
                        onSelected: (_) => _selectFullWeek()),
                    ..._weekDays.map((d) => ChoiceChip(
                          label: Text(d[0].toUpperCase() + d.substring(1)),
                          selected: !_todayMode && _selectedDay == d,
                          onSelected: (_) => setState(() {
                            _todayMode = false;
                            _selectedDay = d;
                          }),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This is your regular weekly timetable — substitutions or cancellations '
                  'for a specific date aren\'t reflected here.',
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
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lec = sorted[index];
                    return ListTile(
                      title: Text(subjectNameById[lec.subjectId] ?? 'Subject ${lec.subjectId}'),
                      subtitle: Text(
                        '${lec.dayOfWeek[0].toUpperCase()}${lec.dayOfWeek.substring(1)} • '
                        '${TimeOfDayUtils.displayLabel(lec.startTime)} - ${TimeOfDayUtils.displayLabel(lec.endTime)} • '
                        'Room ${lec.roomNumber}',
                      ),
                      trailing: Text('${lec.studentCount} students',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
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