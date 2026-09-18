import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/update_fee_structure_controller.dart';
import '../../data/models/fee_structure.dart';
import '../../data/models/fee_structure_update_request.dart';

class UpdateFeeStructureScreen extends ConsumerStatefulWidget {
  final FeeStructure structure;
  const UpdateFeeStructureScreen({super.key, required this.structure});

  @override
  ConsumerState<UpdateFeeStructureScreen> createState() => _UpdateFeeStructureScreenState();
}

class _UpdateFeeStructureScreenState extends ConsumerState<UpdateFeeStructureScreen> {
  late final TextEditingController _amountController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.structure.amount.toStringAsFixed(0));
    _isActive = widget.structure.isActive;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final request = FeeStructureUpdateRequest(
      amount: double.tryParse(_amountController.text.trim()),
      isActive: _isActive,
    );

    final result = await ref
        .read(updateFeeStructureControllerProvider.notifier)
        .updateFeeStructure(widget.structure.id, request);
    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fee structure updated')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateFeeStructureControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Update Fee Structure')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text('Academic Year: ${widget.structure.academicYear}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              subtitle: const Text('Turn off to deactivate — no hard delete exists for this'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
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
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}