import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/subjects_list_controller.dart';
import '../../data/models/subject.dart';

class SelectSubjectScreen extends ConsumerStatefulWidget {
  final String title;
  const SelectSubjectScreen({super.key, required this.title});

  @override
  ConsumerState<SelectSubjectScreen> createState() => _SelectSubjectScreenState();
}

class _SelectSubjectScreenState extends ConsumerState<SelectSubjectScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or code',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: subjectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load subjects: $e')),
                data: (subjects) {
                  final filtered = _query.isEmpty
                      ? subjects
                      : subjects.where((s) {
                          final q = _query.toLowerCase();
                          return s.name.toLowerCase().contains(q) ||
                              s.code.toLowerCase().contains(q);
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No subjects found'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final s = filtered[index];
                      return ListTile(
                        title: Text(s.name),
                        subtitle: Text(s.code),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).pop(s),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}