import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/students/presentation/screens/select_student_screen.dart';
import 'package:cms/features/students/data/models/student.dart';
import '../../application/fee_records_list_controller.dart';
import '../../data/models/fee_record.dart';
import 'record_payment_screen.dart';

class PayFeeScreen extends ConsumerStatefulWidget {
  const PayFeeScreen({super.key});

  @override
  ConsumerState<PayFeeScreen> createState() => _PayFeeScreenState();
}

class _PayFeeScreenState extends ConsumerState<PayFeeScreen> {
  Student? _selectedStudent;

  Future<void> _pickStudent() async {
    final selected = await Navigator.of(context).push<Student>(
      MaterialPageRoute(builder: (_) => const SelectStudentScreen(title: 'Select Student')),
    );
    if (selected != null) setState(() => _selectedStudent = selected);
  }

  Future<void> _openRecordPayment(FeeRecord record) async {
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RecordPaymentScreen(record: record)),
    );
    if (paid == true) {
      ref.invalidate(feeRecordsListControllerProvider(studentId: _selectedStudent!.id));
    }
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
      appBar: AppBar(title: const Text('Pay Fee')),
      body: SingleChildScrollView(
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
            const SizedBox(height: 16),
            if (_selectedStudent != null) _buildRecordsList() else const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    final recordsAsync =
        ref.watch(feeRecordsListControllerProvider(studentId: _selectedStudent!.id));

    return recordsAsync.when(
      loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Failed to load: ${friendlyErrorMessage(e)}',
          style: const TextStyle(color: Colors.red)),
      data: (records) {
        if (records.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No fee records for this student')),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          separatorBuilder: (_, unused) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final r = records[index];
            final isPaid = r.status == 'paid';
            return ListTile(
              title: Text('${r.month}/${r.year}'),
              subtitle: Text('Due: ${r.amountDue.toStringAsFixed(0)} • '
                  'Paid: ${r.amountPaid.toStringAsFixed(0)}'),
              trailing: Chip(
                label: Text(r.status[0].toUpperCase() + r.status.substring(1),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: _statusColor(r.status),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              enabled: !isPaid,
              onTap: isPaid ? null : () => _openRecordPayment(r),
            );
          },
        );
      },
    );
  }
}