import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/subjects_list_controller.dart';
import '../../data/models/subject.dart';

class SubjectSearchSection extends ConsumerStatefulWidget {
  final ValueChanged<Subject>? onSubjectTap;
  const SubjectSearchSection({super.key, this.onSubjectTap});

  @override
  ConsumerState<SubjectSearchSection> createState() => SubjectSearchSectionState();
}

class SubjectSearchSectionState extends ConsumerState<SubjectSearchSection> {
  String _query = '';

  Future<void> refresh() async {
    await ref.read(subjectsListControllerProvider.notifier).refresh();
  }

  void _exportStub() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Export — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsListControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 550),
          child: SingleChildScrollView(
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
                      Text('All Subjects',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 220,
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search Subjects',
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
                  subjectsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('Failed to load subjects: $e', style: const TextStyle(color: Colors.red)),
                    ),
                    data: (subjects) => _buildTable(subjects),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTable(List<Subject> subjects) {
    final filtered = _query.isEmpty
        ? subjects
        : subjects.where((s) {
            final q = _query.toLowerCase();
            return s.name.toLowerCase().contains(q) || s.code.toLowerCase().contains(q);
          }).toList();

    if (subjects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No subjects yet')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Status')),
        ],
        rows: filtered
            .map((s) => DataRow(
                  onSelectChanged: widget.onSubjectTap == null
                      ? null
                      : (selected) {
                          if (selected == true) widget.onSubjectTap!(s);
                        },
                  cells: [
                    DataCell(Text(s.name)),
                    DataCell(Text(s.code)),
                    DataCell(Text(
                      s.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(color: s.isActive ? Colors.green : Colors.grey),
                    )),
                  ],
                ))
            .toList(),
      ),
    );
  }
}