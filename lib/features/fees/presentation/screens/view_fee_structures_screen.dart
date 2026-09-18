import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/fee_structures_list_controller.dart';
import '../../data/models/fee_structure.dart';
import 'update_fee_structure_screen.dart';

class ViewFeeStructuresScreen extends ConsumerStatefulWidget {
  const ViewFeeStructuresScreen({super.key});

  @override
  ConsumerState<ViewFeeStructuresScreen> createState() => _ViewFeeStructuresScreenState();
}

class _ViewFeeStructuresScreenState extends ConsumerState<ViewFeeStructuresScreen> {
  SchoolClass? _selectedClass;
  final _yearController = TextEditingController();
  String? _appliedYear;
  bool _showInactive = false;

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _openUpdate(FeeStructure structure) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UpdateFeeStructureScreen(structure: structure)),
    );
    if (updated == true) {
      ref.invalidate(feeStructuresListControllerProvider(
        classId: _selectedClass?.id,
        academicYear: _appliedYear,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));

    return Scaffold(
      appBar: AppBar(title: const Text('View Fee Structure')),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    decoration: const InputDecoration(labelText: 'Academic Year (optional)'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _appliedYear = _yearController.text.trim()),
                  child: const Text('Apply'),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show deactivated'),
              value: _showInactive,
              onChanged: (v) => setState(() => _showInactive = v),
            ),
            const SizedBox(height: 12),
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
    final structuresAsync = ref.watch(feeStructuresListControllerProvider(
      classId: _selectedClass?.id,
      academicYear: (_appliedYear?.isEmpty ?? true) ? null : _appliedYear,
    ));

    return structuresAsync.when(
      loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('Failed to load: ${friendlyErrorMessage(e)}',
            style: const TextStyle(color: Colors.red)),
      ),
      data: (structures) {
        final visible =
            _showInactive ? structures : structures.where((s) => s.isActive).toList();
        if (visible.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No fee structures found')),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Class')),
              DataColumn(label: Text('Year')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Status')),
            ],
            rows: visible
                .map((s) => DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) _openUpdate(s);
                      },
                      cells: [
                        DataCell(Text(classNameById[s.classId] ?? s.classId)),
                        DataCell(Text(s.academicYear)),
                        DataCell(Text(s.amount.toStringAsFixed(0))),
                        DataCell(Text(
                          s.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(color: s.isActive ? Colors.green : Colors.grey),
                        )),
                      ],
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}