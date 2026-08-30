import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';
import 'package:cms/features/subjects/data/models/subject.dart';
import '../../application/teacher_search_controller.dart';
import '../../data/models/teacher.dart';

class TeacherSearchSection extends ConsumerStatefulWidget {
  const TeacherSearchSection({super.key});

  @override
  ConsumerState<TeacherSearchSection> createState() => TeacherSearchSectionState();
}

class TeacherSearchSectionState extends ConsumerState<TeacherSearchSection> {
  final _departmentController = TextEditingController();
  String? _department;
  Subject? _selectedSubject;
  int _page = 1;
  String _query = '';

  @override
  void dispose() {
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    await ref
        .read(teacherSearchControllerProvider(
          department: _department,
          subjectId: _selectedSubject?.id,
          page: _page,
        ).notifier)
        .refresh();
  }

  void _applyDepartmentFilter() {
    setState(() {
      _department =
          _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim();
      _page = 1;
    });
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search Teachers', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: 'Department'),
                  onSubmitted: (_) => _applyDepartmentFilter(),
                ),
              ),
              subjectsAsync.when(
                loading: () => const SizedBox(width: 200, child: LinearProgressIndicator()),
                error: (e, _) => const SizedBox.shrink(),
                data: (subjects) => SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<Subject?>(
                    initialValue: _selectedSubject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: [
                      const DropdownMenuItem<Subject?>(value: null, child: Text('All Subjects')),
                      ...subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))),
                    ],
                    onChanged: (v) => setState(() {
                      _selectedSubject = v;
                      _page = 1;
                    }),
                  ),
                ),
              ),
              ElevatedButton(onPressed: _applyDepartmentFilter, child: const Text('Apply')),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultsCard(context),
        ],
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    final teachersAsync = ref.watch(teacherSearchControllerProvider(
      department: _department,
      subjectId: _selectedSubject?.id,
      page: _page,
    ));

    return Card(
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
                Text('All Teachers',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name',
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
            teachersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Failed to load teachers: $e', style: const TextStyle(color: Colors.red)),
              ),
              data: (teachers) => _buildTableAndPagination(teachers),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableAndPagination(List<Teacher> teachers) {
    final filtered = _query.isEmpty
        ? teachers
        : teachers.where((t) => t.fullName.toLowerCase().contains(_query.toLowerCase())).toList();

    if (teachers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No teachers found')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Department')),
              DataColumn(label: Text('Qualification')),
              DataColumn(label: Text('Status')),
            ],
            rows: filtered
                .map((t) => DataRow(cells: [
                      DataCell(Text(t.fullName)),
                      DataCell(Text(t.department ?? '-')),
                      DataCell(Text(t.qualification ?? '-')),
                      DataCell(Text(
                        t.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(color: t.isActive ? Colors.green : Colors.grey),
                      )),
                    ]))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (_query.isEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _page > 1 ? () => setState(() => _page -= 1) : null,
              ),
              Text('Page $_page'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: teachers.length == teacherSearchPageSize
                    ? () => setState(() => _page += 1)
                    : null,
              ),
            ],
          ),
      ],
    );
  }
}