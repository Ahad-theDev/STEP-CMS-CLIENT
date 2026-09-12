import 'package:cms/features/attendance/presentation/widgets/trend_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/class_trends_controller.dart';

class ClassTrendsScreen extends ConsumerStatefulWidget {
  const ClassTrendsScreen({super.key});

  @override
  ConsumerState<ClassTrendsScreen> createState() => _ClassTrendsScreenState();
}

class _ClassTrendsScreenState extends ConsumerState<ClassTrendsScreen> {
  SchoolClass? _selectedClass;
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
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));

    return Scaffold(
      appBar: AppBar(title: const Text('Class Attendance Trends')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            classesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                'Failed to load classes: ${friendlyErrorMessage(e)}',
                style: const TextStyle(color: Colors.red),
              ),
              data: (classes) => DropdownButtonFormField<SchoolClass>(
                initialValue: _selectedClass,
                decoration: const InputDecoration(labelText: 'Select Class'),
                items: classes
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.name} - ${c.section}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedClass = v),
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
            if (_selectedClass != null) Expanded(child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final trendsAsync = ref.watch(
      classTrendsControllerProvider(
        classId: _selectedClass!.id,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      ),
    );

    return trendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Failed to load trends: ${friendlyErrorMessage(e)}'),
      ),
      data: (response) =>
          SingleChildScrollView(child: TrendPieChart(points: response.trends)),
    );
  }
}
