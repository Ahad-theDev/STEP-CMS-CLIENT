import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/fee_summary_controller.dart';

class FeeSummaryScreen extends ConsumerStatefulWidget {
  const FeeSummaryScreen({super.key});

  @override
  ConsumerState<FeeSummaryScreen> createState() => _FeeSummaryScreenState();
}

class _FeeSummaryScreenState extends ConsumerState<FeeSummaryScreen> {
  SchoolClass? _selectedClass;
  int? _fromMonth;
  int? _fromYear;
  int? _toMonth;
  int? _toYear;

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Summary')),
      body: SingleChildScrollView(
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
                  ...classes.map(
                      (c) => DropdownMenuItem(value: c, child: Text('${c.name} - ${c.section}'))),
                ],
                onChanged: (v) => setState(() => _selectedClass = v),
              ),
            ),
            const SizedBox(height: 12),
            Text('From', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                SizedBox(width: 120, child: _monthDropdown(_fromMonth, (v) => setState(() => _fromMonth = v))),
                SizedBox(width: 120, child: _yearDropdown(_fromYear, (v) => setState(() => _fromYear = v))),
              ],
            ),
            const SizedBox(height: 12),
            Text('To', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                SizedBox(width: 120, child: _monthDropdown(_toMonth, (v) => setState(() => _toMonth = v))),
                SizedBox(width: 120, child: _yearDropdown(_toYear, (v) => setState(() => _toYear = v))),
              ],
            ),
            const SizedBox(height: 20),
            classesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (classes) {
                final classNameById = {
                  for (final c in classes) c.id: '${c.name} - ${c.section}',
                };
                return _buildContent(classNameById);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthDropdown(int? value, ValueChanged<int?> onChanged) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Month'),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Any')),
        ...List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
      ],
      onChanged: onChanged,
    );
  }

  Widget _yearDropdown(int? value, ValueChanged<int?> onChanged) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Year'),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Any')),
        ...List.generate(6, (i) {
          final y = DateTime.now().year - 2 + i;
          return DropdownMenuItem(value: y, child: Text('$y'));
        }),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildContent(Map<String, String> classNameById) {
    final summaryAsync = ref.watch(feeSummaryControllerProvider(
      classId: _selectedClass?.id,
      fromMonth: _fromMonth,
      fromYear: _fromYear,
      toMonth: _toMonth,
      toYear: _toYear,
    ));

    return summaryAsync.when(
      loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Failed to load summary: ${friendlyErrorMessage(e)}',
          style: const TextStyle(color: Colors.red)),
      data: (response) {
        final s = response.summary;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statCard('Total Due', s.totalDue.toStringAsFixed(0), Colors.blueGrey),
                _statCard('Total Collected', s.totalCollected.toStringAsFixed(0), Colors.green),
                _statCard('Efficiency', '${s.collectionEfficiency.toStringAsFixed(1)}%', Colors.indigo),
                _statCard('Paid', '${s.studentsPaid}', Colors.green),
                _statCard('Partial', '${s.studentsPartial}', Colors.orange),
                _statCard('Unpaid', '${s.studentsUnpaid}', Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            Text('By Class', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (response.breakdown.isEmpty)
              const Text('No breakdown data for this range')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Class')),
                    DataColumn(label: Text('Due')),
                    DataColumn(label: Text('Collected')),
                    DataColumn(label: Text('Efficiency')),
                  ],
                  rows: response.breakdown
                      .map((b) => DataRow(cells: [
                            DataCell(Text(classNameById[b.classId] ?? b.classId)),
                            DataCell(Text(b.due.toStringAsFixed(0))),
                            DataCell(Text(b.collected.toStringAsFixed(0))),
                            DataCell(Text('${b.efficiency.toStringAsFixed(1)}%')),
                          ]))
                      .toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1, red: color.r, green: color.g, blue: color.b),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3, red: color.r, green: color.g, blue: color.b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}