import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/bulk_shift_controller.dart';
import '../../data/models/bulk_shift_request.dart';
import 'package:cms/features/students/data/models/bulk_import_result.dart';

class BulkShiftScreen extends ConsumerStatefulWidget {
  final DateTime date;
  const BulkShiftScreen({super.key, required this.date});

  @override
  ConsumerState<BulkShiftScreen> createState() => _BulkShiftScreenState();
}

class _BulkShiftScreenState extends ConsumerState<BulkShiftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minutesController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _shiftLater = true;
  BulkImportResult? _result;

  @override
  void dispose() {
    _minutesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    final request = BulkShiftRequest(
      date: widget.date,
      shiftMinutes: _shiftLater ? minutes : -minutes,
      reason: _reasonController.text.trim(),
    );

    final result = await ref.read(bulkShiftControllerProvider.notifier).shift(request);
    if (!mounted || result == null) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bulkShiftControllerProvider);
    final isLoading = state.isLoading;
    final dateLabel =
        '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Shift Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Shifting all lectures on $dateLabel',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Later'),
                    selected: _shiftLater,
                    onSelected: (v) => setState(() => _shiftLater = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Earlier'),
                    selected: !_shiftLater,
                    onSelected: (v) => setState(() => _shiftLater = false),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minutesController,
                decoration: const InputDecoration(labelText: 'Minutes to shift'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                    : const Text('Apply Shift'),
              ),
              if (_result != null) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                Text('Shift Complete', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  children: [
                    Text('Total: ${_result!.total}'),
                    Text('Success: ${_result!.success}', style: const TextStyle(color: Colors.green)),
                    Text('Failed: ${_result!.failed}',
                        style: TextStyle(color: _result!.failed > 0 ? Colors.red : Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Done'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}