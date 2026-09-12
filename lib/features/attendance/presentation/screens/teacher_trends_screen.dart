import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import '../../application/teacher_trends_controller.dart';
import '../widgets/trend_pie_chart.dart';

class TeacherTrendsScreen extends ConsumerStatefulWidget {
  const TeacherTrendsScreen({super.key});

  @override
  ConsumerState<TeacherTrendsScreen> createState() => _TeacherTrendsScreenState();
}

class _TeacherTrendsScreenState extends ConsumerState<TeacherTrendsScreen> {
  Teacher? _selectedTeacher;
  DateTime _dateFrom = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dateTo = DateTime.now();

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _dateFrom, end: _dateTo),
    );
    if (picked != null) {
      setState(() {
        _dateFrom = picked.start;
        _dateTo = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(teachersListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Attendance Trends')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            teachersAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load teachers: ${friendlyErrorMessage(e)}',
                  style: const TextStyle(color: Colors.red)),
              data: (teachers) => DropdownButtonFormField<Teacher>(
                initialValue: _selectedTeacher,
                decoration: const InputDecoration(labelText: 'Select Teacher'),
                items:
                    teachers.map((t) => DropdownMenuItem(value: t, child: Text(t.fullName))).toList(),
                onChanged: (v) => setState(() => _selectedTeacher = v),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickRange,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date Range'),
                child: Text('${_fmt(_dateFrom)} to ${_fmt(_dateTo)}'),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedTeacher != null) Expanded(child: _buildCharts()),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts() {
    final trendsAsync = ref.watch(teacherTrendsControllerProvider(
      teacherId: _selectedTeacher!.id,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    ));
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));

    return trendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load trends: ${friendlyErrorMessage(e)}')),
      data: (response) {
        if (response.classes.isEmpty) {
          return const Center(child: Text('No attendance data for this teacher in this range'));
        }
        final classNameById = {
          for (final c in classesAsync.valueOrNull ?? []) c.id: '${c.name}-${c.section}',
        };
        return ListView(
          children: response.classes.map((classTrend) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(classNameById[classTrend.classId] ?? classTrend.classId,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TrendPieChart(points: classTrend.trends),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}