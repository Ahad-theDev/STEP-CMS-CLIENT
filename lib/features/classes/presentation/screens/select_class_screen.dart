import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/classes_list_controller.dart';
// ignore: unused_import
import '../../data/models/school_class.dart';

class SelectClassScreen extends ConsumerStatefulWidget {
  final String title;
  const SelectClassScreen({super.key, required this.title});

  @override
  ConsumerState<SelectClassScreen> createState() => _SelectClassScreenState();
}

class _SelectClassScreenState extends ConsumerState<SelectClassScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or section',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: classesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load classes: $e')),
                data: (classes) {
                  final filtered = _query.isEmpty
                      ? classes
                      : classes.where((c) {
                          final q = _query.toLowerCase();
                          return c.name.toLowerCase().contains(q) ||
                              c.section.toLowerCase().contains(q);
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No classes found'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return ListTile(
                        title: Text('${c.name} - ${c.section}'),
                        subtitle: Text(c.academicYear),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).pop(c),
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