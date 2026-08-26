import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/bulk_import_students_controller.dart';
import '../../data/models/bulk_import_result.dart';

class BulkImportStudentsScreen extends ConsumerStatefulWidget {
  const BulkImportStudentsScreen({super.key});

  @override
  ConsumerState<BulkImportStudentsScreen> createState() => _BulkImportStudentsScreenState();
}

class _BulkImportStudentsScreenState extends ConsumerState<BulkImportStudentsScreen> {
  String? _pickedPath;
  String? _pickedName;
  BulkImportResult? _result;

  Future<void> _pickFile() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (picked == null || picked.isEmpty || picked.first.path == null) return;
    setState(() {
      _pickedPath = picked.first.path;
      _pickedName = picked.first.name;
      _result = null;
    });
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
    }
    return error.toString();
  }

  Future<void> _submit() async {
    if (_pickedPath == null || _pickedName == null) return;
    final result = await ref
        .read(bulkImportStudentsControllerProvider.notifier)
        .importFile(_pickedPath!, _pickedName!);
    if (!mounted || result == null) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bulkImportStudentsControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Import Students')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              'CSV columns required: full_name, roll_number, class_id, guardian_name, '
              'guardian_phone, admission_date (YYYY-MM-DD), monthly_fee, discount (optional).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'Note: class_id must be the class\'s UUID, not its name — '
              'export the class list first if you need to look these up.',
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
                child: Text('Failed: ${_friendlyError(state.error!)}',
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
}