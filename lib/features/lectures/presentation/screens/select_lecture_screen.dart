import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/lecture_search_controller.dart';

class SelectLectureScreen extends ConsumerStatefulWidget {
  final String title;
  const SelectLectureScreen({super.key, required this.title});

  @override
  ConsumerState<SelectLectureScreen> createState() => _SelectLectureScreenState();
}

class _SelectLectureScreenState extends ConsumerState<SelectLectureScreen> {
  int _page = 1;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final lecturesAsync = ref.watch(lectureSearchControllerProvider(page: _page));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by day or room',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: lecturesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load lectures: ${friendlyErrorMessage(e)}')),
                data: (lectures) {
                  final filtered = _query.isEmpty
                      ? lectures
                      : lectures.where((l) {
                          final q = _query.toLowerCase();
                          return l.dayOfWeek.toLowerCase().contains(q) ||
                              l.roomNumber.toLowerCase().contains(q);
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No lectures found'));
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final l = filtered[index];
                            return ListTile(
                              title: Text(
                                  '${l.dayOfWeek[0].toUpperCase()}${l.dayOfWeek.substring(1)} • ${TimeOfDayUtils.displayLabel(l.startTime)}-${TimeOfDayUtils.displayLabel(l.endTime)}'),
                              subtitle: Text('Room ${l.roomNumber}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).pop(l),
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
                              onPressed: lectures.length == lectureSearchPageSize
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