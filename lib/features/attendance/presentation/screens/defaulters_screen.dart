import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/defaulters_controller.dart';

class DefaultersScreen extends ConsumerStatefulWidget {
  const DefaultersScreen({super.key});

  @override
  ConsumerState<DefaultersScreen> createState() => _DefaultersScreenState();
}

class _DefaultersScreenState extends ConsumerState<DefaultersScreen> {
  double _threshold = 75.0;
  SchoolClass? _selectedClass; // null = school-wide
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
      appBar: AppBar(title: const Text('Attendance Defaulters')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            classesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load classes: ${friendlyErrorMessage(e)}',
                  style: const TextStyle(color: Colors.red)),
              data: (classes) => DropdownButtonFormField<SchoolClass?>(
                initialValue: _selectedClass,
                decoration: const InputDecoration(labelText: 'Class (optional)'),
                items: [
                  const DropdownMenuItem<SchoolClass?>(value: null, child: Text('All Classes')),
                  ...classes.map((c) => DropdownMenuItem(value: c, child: Text('${c.name} - ${c.section}'))),
                ],
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
            const SizedBox(height: 12),
            Text('Threshold: ${_threshold.toStringAsFixed(0)}% present'),
            Slider(
              value: _threshold,
              min: 0,
              max: 100,
              divisions: 20,
              label: '${_threshold.toStringAsFixed(0)}%',
              onChanged: (v) => setState(() => _threshold = v),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final defaultersAsync = ref.watch(defaultersControllerProvider(
      threshold: _threshold,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      classId: _selectedClass?.id,
    ));

    return defaultersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load defaulters: ${friendlyErrorMessage(e)}')),
      data: (response) {
        if (response.defaulters.isEmpty) {
          return Center(
            child: Text(
              'No students below ${_threshold.toStringAsFixed(0)}% in this range',
              textAlign: TextAlign.center,
            ),
          );
        }
        final sorted = [...response.defaulters]
          ..sort((a, b) => a.percentagePresent.compareTo(b.percentagePresent));

        return ListView.separated(
          itemCount: sorted.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final d = sorted[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: Text(
                  '${d.percentagePresent.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(d.studentName),
              subtitle: Text('${d.totalLectures} lecture(s) in range'),
            );
          },
        );
      },
    );
  }
}