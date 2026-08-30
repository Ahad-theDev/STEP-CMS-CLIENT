import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/teachers_list_controller.dart';

class SelectTeacherScreen extends ConsumerStatefulWidget {
  final String title;
  const SelectTeacherScreen({super.key, required this.title});

  @override
  ConsumerState<SelectTeacherScreen> createState() => _SelectTeacherScreenState();
}

class _SelectTeacherScreenState extends ConsumerState<SelectTeacherScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(teachersListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or department',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: teachersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load teachers: $e')),
                data: (teachers) {
                  final filtered = _query.isEmpty
                      ? teachers
                      : teachers.where((t) {
                          final q = _query.toLowerCase();
                          return t.fullName.toLowerCase().contains(q) ||
                              (t.department?.toLowerCase().contains(q) ?? false);
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No teachers found'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      return ListTile(
                        title: Text(t.fullName),
                        subtitle: Text(t.department ?? 'No department set'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).pop(t),
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