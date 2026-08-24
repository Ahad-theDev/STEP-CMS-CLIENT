import 'package:cms/features/students/application/students_list_controller.dart';
import 'package:cms/features/students/presentation/screens/add_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentsListScreen extends ConsumerWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentsListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Students")),
      body: studentAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text("No students yet"));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(studentsListControllerProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                return ListTile(
                  title: Text(s.fullName),
                  subtitle: Text(
                    'Roll #${s.rollNumber} • Fee: ${s.monthlyFee}',
                  ),
                  trailing: s.isActive
                      ? null
                      : const Icon(Icons.block, color: Colors.grey),
                );
              },
            ),
          );
        },
        error: (e, _) => Center(child: Text("Failed to load Students: $e")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddStudentScreen()),
          );
          if (created == true) {
            ref.read(studentsListControllerProvider.notifier).refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
