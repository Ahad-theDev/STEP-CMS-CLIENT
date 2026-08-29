import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../application/student_search_controller.dart';

class SelectStudentScreen extends ConsumerStatefulWidget {
  final String title;
  const SelectStudentScreen({super.key, required this.title});

  @override
  ConsumerState<SelectStudentScreen> createState() => _SelectStudentScreenState();
}

class _SelectStudentScreenState extends ConsumerState<SelectStudentScreen> {
  SchoolClass? _selectedClass;
  int _page = 1;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            classesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('Failed to load classes: $e', style: const TextStyle(color: Colors.red)),
              data: (classes) => DropdownButtonFormField<SchoolClass>(
                initialValue: _selectedClass,
                decoration: const InputDecoration(labelText: 'Select Class'),
                items: classes
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.name} - ${c.section} (${c.academicYear})'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedClass = v;
                  _page = 1;
                  _query = '';
                }),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedClass != null) ...[
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name or roll number',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildStudentList()),
            ] else
              const Expanded(child: Center(child: Text('Select a class to see its students'))),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    final studentsAsync =
        ref.watch(studentSearchControllerProvider(classId: _selectedClass!.id, page: _page));

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load students: $e')),
      data: (students) {
        final filtered = _query.isEmpty
            ? students
            : students.where((s) {
                final q = _query.toLowerCase();
                return s.fullName.toLowerCase().contains(q) || s.rollNumber.toLowerCase().contains(q);
              }).toList();

        if (students.isEmpty) {
          return const Center(child: Text('No students in this class'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final s = filtered[index];
                  return ListTile(
                    title: Text(s.fullName),
                    subtitle: Text('Roll #${s.rollNumber}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pop(s),
                  );
                },
              ),
            ),
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
      },
    );
  }
}