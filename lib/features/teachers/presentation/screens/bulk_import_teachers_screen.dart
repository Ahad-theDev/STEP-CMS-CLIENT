import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/students/data/models/bulk_import_result.dart';
import '../../application/bulk_import_teachers_controller.dart';

class BulkImportTeachersScreen extends ConsumerStatefulWidget {
  const BulkImportTeachersScreen({super.key});

  @override
  ConsumerState<BulkImportTeachersScreen> createState() => _BulkImportTeachersScreenState();
}

class _BulkImportTeachersScreenState extends ConsumerState<BulkImportTeachersScreen> {
  String? _pickedPath;
  String? _pickedName;
  BulkImportResult? _result;

  Future<void> _pickFile() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (picked.isEmpty) return;
    setState(() {
      _pickedPath = picked.first.path;
      _pickedName = picked.first.name;
      _result = null;
    });
  }

  Future<void> _submit() async {
    if (_pickedPath == null || _pickedName == null) return;
    final result = await ref
        .read(bulkImportTeachersControllerProvider.notifier)
        .importFile(_pickedPath!, _pickedName!);
    if (!mounted || result == null) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bulkImportTeachersControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Import Teachers')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              'CSV column names not yet confirmed against the backend — '
              'ask before relying on this for a real import.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: isLoading ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(_pickedName ?? 'Choose CSV File'),
            ),
            const SizedBox(height: 16),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Failed: ${friendlyErrorMessage(state.error!)}',
                    style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: (isLoading || _pickedPath == null) ? null : _submit,
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Import'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text('Import Complete', style: Theme.of(context).textTheme.titleMedium),
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
              if (_result!.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Errors', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ..._result!.errors.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('Row ${e.row}: ${e.error}', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}