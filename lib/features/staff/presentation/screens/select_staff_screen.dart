import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/staff_list_controller.dart';

class SelectStaffScreen extends ConsumerStatefulWidget {
  final String title;
  const SelectStaffScreen({super.key, required this.title});

  @override
  ConsumerState<SelectStaffScreen> createState() => _SelectStaffScreenState();
}

class _SelectStaffScreenState extends ConsumerState<SelectStaffScreen> {
  int _page = 1;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListControllerProvider(page: _page));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or designation',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: staffAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load staff: $e')),
                data: (staffList) {
                  final filtered = _query.isEmpty
                      ? staffList
                      : staffList.where((s) {
                          final q = _query.toLowerCase();
                          return s.fullName.toLowerCase().contains(q) ||
                              (s.designation?.toLowerCase().contains(q) ?? false);
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No staff found'));
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
                              subtitle: Text(s.designation ?? 'No designation set'),
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
                              onPressed: staffList.length == staffPageSize
                                  ? () => setState(() => _page += 1)
                                  : null,
                            ),
                          ],
                        ),
                    ],
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