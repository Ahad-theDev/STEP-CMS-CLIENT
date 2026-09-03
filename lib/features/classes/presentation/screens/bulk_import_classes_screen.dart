import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/students/data/models/bulk_import_result.dart';
import '../../application/bulk_import_classes_controller.dart';

class BulkImportClassesScreen extends ConsumerStatefulWidget {
  const BulkImportClassesScreen({super.key});

  @override
  ConsumerState<BulkImportClassesScreen> createState() => _BulkImportClassesScreenState();
}

class _BulkImportClassesScreenState extends ConsumerState<BulkImportClassesScreen> {
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

  Widget _buildResultSummary(BulkImportResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Import Complete', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            Text('Total: ${result.total}'),
            Text('Success: ${result.success}', style: const TextStyle(color: Colors.green)),
            Text('Failed: ${result.failed}',
                style: TextStyle(color: result.failed > 0 ? Colors.red : Colors.grey)),
          ],
        ),
        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Errors', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...result.errors.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Row ${e.row}: ${e.error}', style: const TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _submit() async {
    if (_pickedPath == null || _pickedName == null) return;
    final result = await ref
        .read(bulkImportClassesControllerProvider.notifier)
        .importFile(_pickedPath!, _pickedName!);
    if (!mounted || result == null) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bulkImportClassesControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Import Classes')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              'CSV columns required: name, section, academic_year, '
              'class_teacher_id (optional).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
              _buildResultSummary(_result!),
            ],
          ],
        ),
      ),
    );
  }
}