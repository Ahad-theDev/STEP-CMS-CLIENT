import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../classes/application/classes_list_controller.dart';
import '../../../classes/data/models/school_class.dart';
import '../../application/student_search_controller.dart';
import '../../data/models/student.dart';

const int studentSearchPageSize = 10;

class StudentSearchSection extends ConsumerStatefulWidget {
  const StudentSearchSection({
    super.key,
    this.onStudentTap,
  });

  final ValueChanged<Student>? onStudentTap;

  @override
  ConsumerState<StudentSearchSection> createState() => StudentSearchSectionState();
}

class StudentSearchSectionState extends ConsumerState<StudentSearchSection> {
  SchoolClass? _selectedClass;
  int _page = 1;
  String _query = '';

  void _onClassChanged(SchoolClass? cls) {
    setState(() {
      _selectedClass = cls;
      _page = 1;
      _query = '';
    });
  }

  /// Called by the parent screen after a new student is created, so the
  /// currently-viewed page reflects it without the admin manually refreshing.
  Future<void> refreshIfClassSelected() async {
    final cls = _selectedClass;
    if (cls == null) return;
    await ref
        .read(studentSearchControllerProvider(classId: cls.id, page: _page).notifier)
        .refresh();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search Students by Class', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          classesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) =>
                Text('Failed to load classes: $e', style: const TextStyle(color: Colors.red)),
            data: (classes) {
              return DropdownButtonFormField<SchoolClass>(
                initialValue: _selectedClass,
                decoration: const InputDecoration(labelText: 'Select Class'),
                items: classes
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.name} - ${c.section} (${c.academicYear})'),
                        ))
                    .toList(),
                onChanged: _onClassChanged,
              );
            },
          ),
          const SizedBox(height: 16),
          if (_selectedClass != null) _buildResultsCard(context),
        ],
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    final cls = _selectedClass!;
    final studentsAsync = ref.watch(studentSearchControllerProvider(classId: cls.id, page: _page));

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
                Text(
                  'Students in ${cls.name}-${cls.section}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search Student',
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
            studentsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Failed to load students: $e', style: const TextStyle(color: Colors.red)),
              ),
              data: (students) => _buildTableAndPagination(students),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableAndPagination(List<Student> students) {
    final filtered = _query.isEmpty
        ? students
        : students.where((s) {
            final q = _query.toLowerCase();
            return s.fullName.toLowerCase().contains(q) ||
                s.rollNumber.toLowerCase().contains(q);
          }).toList();

    if (students.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No students in this class yet')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final s = filtered[index];
            return ListTile(
              title: Text(s.fullName),
              subtitle: Text('Roll #${s.rollNumber}'),
              trailing: Text(
                s.isActive ? 'Active' : 'Inactive',
                style: TextStyle(color: s.isActive ? Colors.green : Colors.grey),
              ),
              onTap: () {
                if (widget.onStudentTap != null) {
                  widget.onStudentTap!(s);
                }
              },
            );
          },
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
                onPressed: students.length == studentSearchPageSize
                    ? () => setState(() => _page += 1)
                    : null,
              ),
            ],
          ),
      ],
    );
  }
}