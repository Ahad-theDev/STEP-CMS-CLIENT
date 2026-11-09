import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/features/lectures/application/my_schedule_controller.dart';
import 'package:cms/features/lectures/data/models/my_schedule_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';

const List<String> _weekDays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

class MyScheduleScreen extends ConsumerStatefulWidget {
  const MyScheduleScreen({super.key, this.markAttendanceOnly = false});
  final bool markAttendanceOnly;

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
    _todayDate = DateTime(
      now.year,
      now.month,
      now.day,
    ); // stable for the life of this screen
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
    if (picked != null && mounted) {
      setState(() {
        _todayMode = false;
        _selectedDay = null;
        _customDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _refreshSchedule() {
    ref.invalidate(
      myScheduleControllerProvider(
        day: _selectedDay,
        date: _todayMode ? _todayDate : _customDate,
      ),
    );
  }

  void _showLectureDetails(MyScheduleLecture lec, String? subjectName) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName ?? 'Subject ${lec.subjectId}',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.schedule_rounded),
                  title: Text(
                    '${lec.dayOfWeek[0].toUpperCase()}${lec.dayOfWeek.substring(1)} • '
                    '${TimeOfDayUtils.displayLabel(lec.startTime)} - ${TimeOfDayUtils.displayLabel(lec.endTime)}',
                  ),
                  subtitle: const Text('Scheduled Time'),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.meeting_room_outlined),
                  title: Text('Room ${lec.roomNumber}'),
                  subtitle: const Text('Classroom / Hall'),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.people_outline_rounded),
                  title: Text('${lec.studentCount} students enrolled'),
                  subtitle: const Text('Enrolled Students'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFilterDate = _todayMode ? _todayDate : _customDate;

    final scheduleAsync = ref.watch(
      myScheduleControllerProvider(
        day: _selectedDay,
        date: effectiveFilterDate,
      ),
    );
    final subjectsAsync = ref.watch(subjectsListControllerProvider);
    final subjectNameById = {
      for (final s in subjectsAsync.valueOrNull ?? []) s.id: s.name,
    };

    return CampusPage(
      appBar: AppBar(
        title: const Text('My Schedule'),
        actions: [
          IconButton(
            tooltip: 'Refresh schedule',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshSchedule,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Pick Date',
            onPressed: _pickCustomDate,
          ),
        ],
      ),
      body: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .4,
            ),
            child: SingleChildScrollView(
              child: Padding(
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
                          selected:
                              !_todayMode &&
                              _selectedDay == null &&
                              _customDate == null,
                          onSelected: (_) => _selectFullWeek(),
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.event, size: 16),
                          label: Text(
                            _customDate != null
                                ? _fmt(_customDate!)
                                : 'Pick Date',
                          ),
                          selected: _customDate != null,
                          onSelected: (_) => _pickCustomDate(),
                        ),
                        ..._weekDays.map(
                          (d) => ChoiceChip(
                            label: Text(d[0].toUpperCase() + d.substring(1)),
                            selected:
                                !_todayMode &&
                                _selectedDay == d &&
                                _customDate == null,
                            onSelected: (_) => setState(() {
                              _todayMode = false;
                              _customDate = null;
                              _selectedDay = d;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _customDate != null
                          ? 'Showing timetable for ${_fmt(_customDate!)}.'
                          : _todayMode
                          ? 'Showing lectures scheduled for today.'
                          : 'Weekly timetable template.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: scheduleAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load schedule: ${friendlyErrorMessage(e)}'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refreshSchedule,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (schedule) {
                if (schedule.lectures.isEmpty) {
                  return const Center(child: Text('No lectures scheduled'));
                }
                final sorted = [...schedule.lectures]
                  ..sort((a, b) {
                    final dayCompare = _weekDays
                        .indexOf(a.dayOfWeek)
                        .compareTo(_weekDays.indexOf(b.dayOfWeek));
                    if (dayCompare != 0) return dayCompare;
                    return a.startTime.compareTo(b.startTime);
                  });

                return ListView.separated(
                  itemCount: sorted.length,
                  separatorBuilder: (_, unusedParam) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lec = sorted[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        subjectNameById[lec.subjectId] ??
                            'Subject ${lec.subjectId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${lec.dayOfWeek[0].toUpperCase()}${lec.dayOfWeek.substring(1)} • '
                          '${TimeOfDayUtils.displayLabel(lec.startTime)} - ${TimeOfDayUtils.displayLabel(lec.endTime)} • '
                          'Room ${lec.roomNumber}',
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${lec.studentCount} students',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      onTap: () => _showLectureDetails(
                        lec,
                        subjectNameById[lec.subjectId],
                      ),
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
