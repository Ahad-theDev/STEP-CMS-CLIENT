import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/classes_list_controller.dart';
import '../../data/models/school_class.dart';
import '../screens/view_class_screen.dart';

class ClassSearchSection extends ConsumerStatefulWidget {
  const ClassSearchSection({
    super.key,
    this.onClassTap,
  });

  final ValueChanged<SchoolClass>? onClassTap;

  @override
  ConsumerState<ClassSearchSection> createState() => ClassSearchSectionState();
}

class ClassSearchSectionState extends ConsumerState<ClassSearchSection> {
  String _query = '';

  Future<void> refresh() async {
    await ref.read(classesListControllerProvider.notifier).refresh();
  }

  void _exportStub() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Export — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('All Classes',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search Classes',
                        prefixIcon: Icon(Icons.search, size: 20),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _exportStub,
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Export'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              classesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('Failed to load classes: $e', style: const TextStyle(color: Colors.red)),
                ),
                data: (classes) => _buildTable(classes),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(List<SchoolClass> classes) {
    final filtered = _query.isEmpty
        ? classes
        : classes.where((c) {
            final q = _query.toLowerCase();
            return c.name.toLowerCase().contains(q) || c.section.toLowerCase().contains(q);
          }).toList();

    if (classes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No classes yet')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Section')),
          DataColumn(label: Text('Academic Year')),
          DataColumn(label: Text('Teacher')),
          DataColumn(label: Text('Status')),
        ],
        rows: filtered
            .map((c) => DataRow(
                onSelectChanged: (b) {
                  if (b == true) {
                    if (widget.onClassTap != null) {
                      widget.onClassTap!(c);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ViewClassScreen(schoolClass: c),
                        ),
                      );
                    }
                  }
                },
                cells: [
                  DataCell(Text(c.name)),
                  DataCell(Text(c.section)),
                  DataCell(Text(c.academicYear)),
                  DataCell(
                    Text(c.classTeacherId == null ? 'Unassigned' : 'Assigned'),
                  ),
                  DataCell(Text(
                    c.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(color: c.isActive ? Colors.green : Colors.grey),
                  )),
                ],
              ))
            .toList(),
      ),
    );
  }
}