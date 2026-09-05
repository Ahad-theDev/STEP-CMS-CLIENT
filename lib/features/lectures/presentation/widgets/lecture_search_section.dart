import 'package:cms/features/subjects/data/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/lecture_search_controller.dart';
import '../../data/models/lecture.dart';

const List<String> weekDays = [
  'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
];

class LectureSearchSection extends ConsumerStatefulWidget {
  final ValueChanged<Lecture>? onLectureTap;
  const LectureSearchSection({super.key, this.onLectureTap});

  @override
  ConsumerState<LectureSearchSection> createState() => LectureSearchSectionState();
}

class LectureSearchSectionState extends ConsumerState<LectureSearchSection> {
  SchoolClass? _selectedClass;
  Teacher? _selectedTeacher;
  String? _selectedDay;
  int _page = 1;

  Future<void> refresh() async {
    await ref
        .read(lectureSearchControllerProvider(
          classId: _selectedClass?.id,
          teacherId: _selectedTeacher?.id,
          dayOfWeek: _selectedDay,
          page: _page,
        ).notifier)
        .refresh();
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final subjectsAsync = ref.watch(subjectsListControllerProvider);

    final Map<String, String> classNameById = {
      for (final c in classesAsync.valueOrNull ?? <SchoolClass>[])
        c.id: '${c.name}-${c.section}'
    };
    final Map<String, String> teacherNameById = {
      for (final t in teachersAsync.valueOrNull ?? <Teacher>[]) t.id: t.fullName
    };
    final Map<String, String> subjectNameById = {
      for (final s in subjectsAsync.valueOrNull ?? <Subject>[]) s.id: s.name
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search Lectures', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              classesAsync.when(
                loading: () => const SizedBox(width: 180, child: LinearProgressIndicator()),
                error: (e, _) => const SizedBox.shrink(),
                data: (classes) => SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<SchoolClass?>(
                    initialValue: _selectedClass,
                    decoration: const InputDecoration(labelText: 'Class'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<SchoolClass?>(value: null, child: Text('All Classes')),
                      ...classes.map((c) =>
                          DropdownMenuItem(value: c, child: Text('${c.name} - ${c.section}'))),
                    ],
                    onChanged: (v) => setState(() {
                      _selectedClass = v;
                      _page = 1;
                    }),
                  ),
                ),
              ),
              teachersAsync.when(
                loading: () => const SizedBox(width: 180, child: LinearProgressIndicator()),
                error: (e, _) => const SizedBox.shrink(),
                data: (teachers) => SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<Teacher?>(
                    initialValue: _selectedTeacher,
                    decoration: const InputDecoration(labelText: 'Teacher'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<Teacher?>(value: null, child: Text('All Teachers')),
                      ...teachers.map((t) => DropdownMenuItem(value: t, child: Text(t.fullName))),
                    ],
                    onChanged: (v) => setState(() {
                      _selectedTeacher = v;
                      _page = 1;
                    }),
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String?>(
                  initialValue: _selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All Days')),
                    ...weekDays.map((d) =>
                        DropdownMenuItem(value: d, child: Text(d[0].toUpperCase() + d.substring(1)))),
                  ],
                  onChanged: (v) => setState(() {
                    _selectedDay = v;
                    _page = 1;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultsCard(context, classNameById, teacherNameById, subjectNameById),
        ],
      ),
    );
  }

  Widget _buildResultsCard(
    BuildContext context,
    Map<String, String> classNameById,
    Map<String, String> teacherNameById,
    Map<String, String> subjectNameById,
  ) {
    final lecturesAsync = ref.watch(lectureSearchControllerProvider(
      classId: _selectedClass?.id,
      teacherId: _selectedTeacher?.id,
      dayOfWeek: _selectedDay,
      page: _page,
    ));

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Lectures',
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            lecturesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Failed to load lectures: ${friendlyErrorMessage(e)}',
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (lectures) =>
                  _buildTableAndPagination(lectures, classNameById, teacherNameById, subjectNameById),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableAndPagination(
    List<Lecture> lectures,
    Map<String, String> classNameById,
    Map<String, String> teacherNameById,
    Map<String, String> subjectNameById,
  ) {
    if (lectures.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No lectures found')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Day')),
              DataColumn(label: Text('Time')),
              DataColumn(label: Text('Room')),
              DataColumn(label: Text('Class')),
              DataColumn(label: Text('Teacher')),
              DataColumn(label: Text('Subject')),
            ],
            rows: lectures
                .map((l) => DataRow(
                      onSelectChanged: widget.onLectureTap == null
                          ? null
                          : (selected) {
                              if (selected == true) widget.onLectureTap!(l);
                            },
                      cells: [
                        DataCell(Text(l.dayOfWeek)),
                        DataCell(Text(
                            '${TimeOfDayUtils.displayLabel(l.startTime)} - ${TimeOfDayUtils.displayLabel(l.endTime)}')),
                        DataCell(Text(l.roomNumber)),
                        DataCell(Text(classNameById[l.classId] ?? '-')),
                        DataCell(Text(teacherNameById[l.teacherId] ?? '-')),
                        DataCell(Text(subjectNameById[l.subjectId] ?? '-')),
                      ],
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _page > 1 ? () => setState(() => _page -= 1) : null,
            ),
            Text('Page $_page'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: lectures.length == lectureSearchPageSize
                  ? () => setState(() => _page += 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}