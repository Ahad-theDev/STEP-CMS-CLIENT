import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/fee_defaulters_controller.dart';
import '../../data/models/fee_defaulters_response.dart';

enum _SortBy { className, month, year, daysOverdue }

class FeeDefaultersScreen extends ConsumerStatefulWidget {
  const FeeDefaultersScreen({super.key});

  @override
  ConsumerState<FeeDefaultersScreen> createState() => _FeeDefaultersScreenState();
}

class _FeeDefaultersScreenState extends ConsumerState<FeeDefaultersScreen> {
  SchoolClass? _selectedClass;
  int? _month;
  int? _year;
  _SortBy _sortBy = _SortBy.daysOverdue;

  Color _statusColor(String status) {
    switch (status) {
      case 'partial':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  List<FeeDefaulterItem> _sorted(List<FeeDefaulterItem> items, Map<String, String> classNameById) {
    final sorted = [...items];
    switch (_sortBy) {
      case _SortBy.className:
        sorted.sort((a, b) =>
            (classNameById[a.classId] ?? '').compareTo(classNameById[b.classId] ?? ''));
        break;
      case _SortBy.month:
        sorted.sort((a, b) => a.month.compareTo(b.month));
        break;
      case _SortBy.year:
        sorted.sort((a, b) => a.year.compareTo(b.year));
        break;
      case _SortBy.daysOverdue:
        sorted.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Defaulters')),
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
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _month,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Any')),
                      ...List.generate(
                          12, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                    ],
                    onChanged: (v) => setState(() => _month = v),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _year,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Any')),
                      ...List.generate(6, (i) {
                        final y = DateTime.now().year - 2 + i;
                        return DropdownMenuItem(value: y, child: Text('$y'));
                      }),
                    ],
                    onChanged: (v) => setState(() => _year = v),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<_SortBy>(
                    initialValue: _sortBy,
                    decoration: const InputDecoration(labelText: 'Sort By'),
                    items: const [
                      DropdownMenuItem(value: _SortBy.daysOverdue, child: Text('Days Overdue')),
                      DropdownMenuItem(value: _SortBy.className, child: Text('Class')),
                      DropdownMenuItem(value: _SortBy.month, child: Text('Month')),
                      DropdownMenuItem(value: _SortBy.year, child: Text('Year')),
                    ],
                    onChanged: (v) => setState(() => _sortBy = v ?? _sortBy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            classesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (classes) {
                final classNameById = {
                  for (final c in classes) c.id: '${c.name} - ${c.section}',
                };
                return _buildTable(classNameById);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(Map<String, String> classNameById) {
    final defaultersAsync = ref.watch(feeDefaultersControllerProvider(
      classId: _selectedClass?.id,
      month: _month,
      year: _year,
    ));

    return defaultersAsync.when(
      loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Failed to load defaulters: ${friendlyErrorMessage(e)}',
          style: const TextStyle(color: Colors.red)),
      data: (response) {
        if (response.defaulters.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No defaulters found for this filter')),
          );
        }
        final sorted = _sorted(response.defaulters, classNameById);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Student')),
              DataColumn(label: Text('Class')),
              DataColumn(label: Text('Month/Year')),
              DataColumn(label: Text('Remaining')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Days Overdue')),
            ],
            rows: sorted
                .map((d) => DataRow(cells: [
                      DataCell(Text(d.studentName)),
                      DataCell(Text(classNameById[d.classId] ?? '-')),
                      DataCell(Text('${d.month}/${d.year}')),
                      DataCell(Text(d.remaining.toStringAsFixed(0))),
                      DataCell(Chip(
                        label: Text(d.status[0].toUpperCase() + d.status.substring(1),
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: _statusColor(d.status),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      DataCell(Text('${d.daysOverdue}')),
                    ]))
                .toList(),
          ),
        );
      },
    );
  }
}