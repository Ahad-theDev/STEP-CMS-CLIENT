import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/students/presentation/screens/select_student_screen.dart';
import 'package:cms/features/students/data/models/student.dart';
import '../../application/fee_records_list_controller.dart';

const List<Map<String, String>> _statusOptions = [
  {'value': 'unpaid', 'label': 'Unpaid'},
  {'value': 'partial', 'label': 'Partial'},
  {'value': 'paid', 'label': 'Paid'},
];

class ViewFeeRecordsScreen extends ConsumerStatefulWidget {
  const ViewFeeRecordsScreen({super.key});

  @override
  ConsumerState<ViewFeeRecordsScreen> createState() => _ViewFeeRecordsScreenState();
}

class _ViewFeeRecordsScreenState extends ConsumerState<ViewFeeRecordsScreen> {
  Student? _selectedStudent;
  int? _month;
  int? _year;
  String? _status;

  Future<void> _pickStudent() async {
    final selected = await Navigator.of(context).push<Student>(
      MaterialPageRoute(builder: (_) => const SelectStudentScreen(title: 'Select Student')),
    );
    if (selected != null) setState(() => _selectedStudent = selected);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Fee Records')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _pickStudent,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Student'),
                child: Text(_selectedStudent == null ? 'Tap to select' : _selectedStudent!.fullName),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedStudent != null) ...[
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
                    width: 160,
                    child: DropdownButtonFormField<String?>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('Any')),
                        ..._statusOptions.map(
                            (o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!))),
                      ],
                      onChanged: (v) => setState(() => _status = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildTable()),
            ] else
              const Expanded(child: Center(child: Text('Select a student to view their fee records'))),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final recordsAsync = ref.watch(feeRecordsListControllerProvider(
      studentId: _selectedStudent!.id,
      month: _month,
      year: _year,
      status: _status,
    ));

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load: ${friendlyErrorMessage(e)}')),
      data: (records) {
        if (records.isEmpty) {
          return const Center(child: Text('No fee records found'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Month')),
              DataColumn(label: Text('Year')),
              DataColumn(label: Text('Due')),
              DataColumn(label: Text('Paid')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Payment Date')),
            ],
            rows: records
                .map((r) => DataRow(cells: [
                      DataCell(Text('${r.month}')),
                      DataCell(Text('${r.year}')),
                      DataCell(Text(r.amountDue.toStringAsFixed(0))),
                      DataCell(Text(r.amountPaid.toStringAsFixed(0))),
                      DataCell(Chip(
                        label: Text(r.status[0].toUpperCase() + r.status.substring(1),
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: _statusColor(r.status),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      DataCell(Text(r.paymentDate ?? '-')),
                    ]))
                .toList(),
          ),
        );
      },
    );
  }
}