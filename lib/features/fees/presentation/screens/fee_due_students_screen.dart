import '../widgets/fee_table_pages.dart';
import 'package:cms/core/utils/natural_order.dart';
import '../widgets/fee_page.dart';
import 'package:cms/features/subjects/application/all_students_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import '../../application/fee_reminders_controller.dart';

class FeeDueStudentsScreen extends ConsumerStatefulWidget {
  const FeeDueStudentsScreen({super.key});

  @override
  ConsumerState<FeeDueStudentsScreen> createState() =>
      _FeeDueStudentsScreenState();
}

class _FeeDueStudentsScreenState extends ConsumerState<FeeDueStudentsScreen> {
  FeeReminderMode _mode = FeeReminderMode.dueToday;
  int _upcomingDays = 3;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsControllerProvider);
    final classesAsync = ref.watch(allClassesControllerProvider);

    final classNameById = {
      for (final c in classesAsync.valueOrNull ?? [])
        c.id: '${c.name} - ${c.section}',
    };
    final studentById = {
      for (final s in studentsAsync.valueOrNull ?? []) s.id: s,
    };

    final remindersAsync = ref.watch(
      feeRemindersControllerProvider(mode: _mode, days: _upcomingDays),
    );

    return FeePage(
      appBar: AppBar(title: const Text('Fee Due Students')),
      body: FeeScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FeeSectionIntro(
              title: 'Upcoming and outstanding fees',
              subtitle: 'Review payments due today, overdue, or coming up.',
            ),
            const SizedBox(height: 22),
            SegmentedButton<FeeReminderMode>(
              segments: const [
                ButtonSegment(
                  value: FeeReminderMode.dueToday,
                  label: Text('Due Today'),
                ),
                ButtonSegment(
                  value: FeeReminderMode.overdue,
                  label: Text('Overdue'),
                ),
                ButtonSegment(
                  value: FeeReminderMode.upcoming,
                  label: Text('Upcoming'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            if (_mode == FeeReminderMode.upcoming) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Within next'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      initialValue: _upcomingDays.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null && parsed > 0) {
                          setState(() => _upcomingDays = parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('days'),
                ],
              ),
            ],
            const SizedBox(height: 16),
            remindersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(
                'Failed to load: ${friendlyErrorMessage(e)}',
                style: const TextStyle(color: Colors.red),
              ),
              data: (response) {
                if (response.records.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No students found for this filter'),
                    ),
                  );
                }
                final records = [...response.records]
                  ..sort((a, b) {
                    final order = naturalCompare(
                      classNameById[studentById[a.studentId]?.classId] ?? '',
                      classNameById[studentById[b.studentId]?.classId] ?? '',
                    );
                    if (order != 0) return order;
                    return naturalCompare(
                      studentById[a.studentId]?.rollNumber ?? a.studentName,
                      studentById[b.studentId]?.rollNumber ?? b.studentName,
                    );
                  });
                return FeeTablePages(
                  key: ValueKey((_mode, _upcomingDays)),
                  records: records,
                  builder: (page) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Student')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Month/Year')),
                        DataColumn(label: Text('Remaining')),
                        DataColumn(label: Text('Due Date')),
                      ],
                      rows: page.map((r) {
                        final student = studentById[r.studentId];
                        final className = student != null
                            ? (classNameById[student.classId] ?? '-')
                            : '-';
                        final phone = student?.guardianPhone ?? '-';
                        return DataRow(
                          cells: [
                            DataCell(Text(r.studentName)),
                            DataCell(Text(className)),
                            DataCell(Text(phone)),
                            DataCell(Text('${r.month}/${r.year}')),
                            DataCell(Text(r.remaining.toStringAsFixed(0))),
                            DataCell(Text(r.dueDate)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
