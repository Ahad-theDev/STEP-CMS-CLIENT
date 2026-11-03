import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/network/dio_client.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../../data/attendance_analytics_repository.dart';
import '../../../data/models/teacher_trends_response.dart';
import '../../widgets/trend_pie_chart.dart';

class _MyAttendanceData {
  const _MyAttendanceData(this.trends, this.names);
  final TeacherTrendsResponse trends;
  final Map<String, String> names;
}

final _myAttendanceProvider = FutureProvider.autoDispose
    .family<_MyAttendanceData, DateTimeRange>((ref, range) async {
      final dio = ref.watch(dioProvider);
      final options =
          (await dio.get('/attendance/students/filter-options')).data as Map;
      final teacherId = options['teacher_id'] as String;
      final trends = await AttendanceAnalyticsRepository(dio).getTeacherTrends(
        teacherId: teacherId,
        dateFrom: range.start,
        dateTo: range.end,
      );
      return _MyAttendanceData(trends, {
        for (final c in options['classes'] as List)
          c['id'] as String: c['label'] as String,
      });
    });

class MyAttendanceScreen extends ConsumerStatefulWidget {
  const MyAttendanceScreen({super.key});
  @override
  ConsumerState<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends ConsumerState<MyAttendanceScreen> {
  late DateTimeRange _range;
  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _range = DateTimeRange(
      start: today.subtract(const Duration(days: 30)),
      end: today,
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );
    if (picked != null && mounted) {
      setState(() => _range = picked);
    }
  }

  void _refresh() => ref.invalidate(_myAttendanceProvider(_range));
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_myAttendanceProvider(_range));
    return CampusPage(
      appBar: AppBar(
        title: const Text('My Attendance'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: CampusScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CampusSectionIntro(
              title: 'Attendance across your classes',
              subtitle:
                  'Student attendance trends for your own lectures. Your teacher profile is selected automatically.',
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _pickRange,
              icon: const Icon(Icons.date_range),
              label: Text('${_fmt(_range.start)} to ${_fmt(_range.end)}'),
            ),
            const SizedBox(height: 20),
            data.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Column(
                children: [
                  Text('Unable to load attendance: ${friendlyErrorMessage(e)}'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
              data: (result) {
                if (result.trends.classes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No attendance records for your classes in this date range.',
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: result.trends.classes.map((c) {
                    final present = c.trends.fold<int>(
                      0,
                      (n, t) => n + t.present,
                    );
                    final absent = c.trends.fold<int>(
                      0,
                      (n, t) => n + t.absent,
                    );
                    final late = c.trends.fold<int>(0, (n, t) => n + t.late);
                    final leave = c.trends.fold<int>(0, (n, t) => n + t.leave);
                    final total = present + absent + late + leave;
                    final percentage = total == 0
                        ? 0.0
                        : (present + late) / total * 100;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.names[c.classId] ?? 'Class attendance',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: CampusStyle.ink,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${percentage.toStringAsFixed(1)}% attendance • $total student attendance records',
                              style: const TextStyle(
                                color: CampusStyle.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Present: $present • Absent: $absent • Late: $late • Leave: $leave',
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Attendance percentage includes Present and Late.',
                              style: TextStyle(
                                color: CampusStyle.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TrendPieChart(points: c.trends),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
