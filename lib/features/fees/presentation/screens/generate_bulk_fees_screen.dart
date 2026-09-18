import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/bulk_generate_fees_controller.dart';
import '../../data/models/fee_generate_request.dart';
import '../../data/models/fee_generate_result.dart';

class GenerateBulkFeesScreen extends ConsumerStatefulWidget {
  const GenerateBulkFeesScreen({super.key});

  @override
  ConsumerState<GenerateBulkFeesScreen> createState() => _GenerateBulkFeesScreenState();
}

class _GenerateBulkFeesScreenState extends ConsumerState<GenerateBulkFeesScreen> {
  final Set<String> _selectedClassIds = {};
  int _month = DateTime.now().month;
  late final TextEditingController _yearController;
  FeeGenerateResult? _result;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: DateTime.now().year.toString());
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedClassIds.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select at least one class')));
      return;
    }
    final year = int.tryParse(_yearController.text.trim());
    if (year == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid year')));
      return;
    }

    final request = BulkGenerateFeesRequest(
      classIds: _selectedClassIds.toList(),
      month: _month,
      year: year,
    );

    final result = await ref.read(bulkGenerateFeesControllerProvider.notifier).generate(request);
    if (!mounted || result == null) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bulkGenerateFeesControllerProvider);
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Bulk Fees')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text('Select Classes', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            classesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load classes: ${friendlyErrorMessage(e)}',
                  style: const TextStyle(color: Colors.red)),
              data: (classes) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: classes.map((c) {
                  final selected = _selectedClassIds.contains(c.id);
                  return FilterChip(
                    label: Text('${c.name} - ${c.section}'),
                    selected: selected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _selectedClassIds.add(c.id);
                      } else {
                        _selectedClassIds.remove(c.id);
                      }
                    }),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _month,
              decoration: const InputDecoration(labelText: 'Month'),
              items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                          DateTime(2000, i + 1).month.toString().padLeft(2, '0') + ' - ' +
                              [
                                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                              ][i]))),
              onChanged: (v) => setState(() => _month = v ?? _month),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
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
                  : const Text('Generate'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text('Generation Complete', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                children: [
                  Text('Total: ${_result!.total}'),
                  Text('Success: ${_result!.success}', style: const TextStyle(color: Colors.green)),
                  Text('Skipped: ${_result!.skipped}', style: const TextStyle(color: Colors.orange)),
                  Text('Failed: ${_result!.failed}',
                      style: TextStyle(color: _result!.failed > 0 ? Colors.red : Colors.grey)),
                ],
              ),
              if (_result!.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Details', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ..._result!.errors.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${e.studentId}: ${e.reason}',
                          style: const TextStyle(color: Colors.red, fontSize: 12)),
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }
}