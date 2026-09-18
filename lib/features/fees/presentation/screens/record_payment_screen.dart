import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/pay_fee_controller.dart';
import '../../data/models/fee_record.dart';
import '../../data/models/payment_request.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  final FeeRecord record;
  const RecordPaymentScreen({super.key, required this.record});

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  late final TextEditingController _amountController;
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final remaining = widget.record.amountDue - widget.record.amountPaid;
    _amountController = TextEditingController(text: remaining.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // backend rejects future payment dates
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    final request = PaymentRequest(amount: amount, paymentDate: _paymentDate);
    final result = await ref.read(payFeeControllerProvider.notifier).pay(widget.record.id, request);
    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment recorded — status is now ${result.status}')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(payFeeControllerProvider);
    final isLoading = state.isLoading;
    final remaining = widget.record.amountDue - widget.record.amountPaid;

    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.record.month}/${widget.record.year}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Due: ${widget.record.amountDue.toStringAsFixed(0)} • '
                'Paid so far: ${widget.record.amountPaid.toStringAsFixed(0)} • '
                'Remaining: ${remaining.toStringAsFixed(0)}'),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Payment Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Payment Date'),
                child: Text(_fmt(_paymentDate)),
              ),
            ),
            const SizedBox(height: 24),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Failed: ${friendlyErrorMessage(state.error!)}',
                    style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );
  }
}