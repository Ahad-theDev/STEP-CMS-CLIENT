import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/network/dio_client.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/core/utils/time_of_day_utils.dart';
import 'mark_lecture_attendance_screen.dart';

final _unmarkedProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, date) async {
      final response = await ref
          .watch(dioProvider)
          .get(
            '/attendance/students/unmarked',
            queryParameters: {'date': date},
          );
      return Map<String, dynamic>.from(response.data);
    });

class UnmarkedLecturesScreen extends ConsumerStatefulWidget {
  const UnmarkedLecturesScreen({super.key});
  @override
  ConsumerState<UnmarkedLecturesScreen> createState() =>
      _UnmarkedLecturesScreenState();
}

class _UnmarkedLecturesScreenState
    extends ConsumerState<UnmarkedLecturesScreen> {
  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _refresh() {
    setState(() {});
    ref.invalidate(_unmarkedProvider(_today()));
  }

  @override
  Widget build(BuildContext context) {
    final date = _today();
    final data = ref.watch(_unmarkedProvider(date));
    return CampusPage(
      appBar: AppBar(
        title: const Text('Unmarked Lectures'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: CampusScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CampusSectionIntro(
              title: 'Attendance still to mark',
              subtitle:
                  'Today’s lectures with no student attendance recorded yet. Your teacher profile is selected automatically.',
            ),
            const SizedBox(height: 18),
            Text(
              'Today • $date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            data.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Column(
                children: [
                  Text('Unable to load lectures: ${friendlyErrorMessage(e)}'),
                  OutlinedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
              data: (response) {
                final entries = List<Map<String, dynamic>>.from(
                  (response['unmarked'] as List).map(
                    (e) => Map<String, dynamic>.from(e),
                  ),
                );
                entries.sort(
                  (a, b) => (a['start_time'] as String).compareTo(
                    b['start_time'] as String,
                  ),
                );
                if (entries.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No unmarked lectures today. Attendance may already be recorded, or no lectures are scheduled.',
                      ),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${entries.length} lecture(s) awaiting attendance'),
                    const SizedBox(height: 12),
                    ...entries.map(
                      (entry) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(Icons.pending_actions),
                          title: Text(
                            entry['subject_name'] as String? ??
                                'Scheduled lecture',
                          ),
                          subtitle: Text(
                            '${entry['class_name'] ?? 'Class'}\n${TimeOfDayUtils.displayLabel(entry['start_time'] as String)} – ${TimeOfDayUtils.displayLabel(entry['end_time'] as String)}\nTap to mark attendance',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MarkLectureAttendanceScreen(
                                  lectureId: entry['lecture_id'] as String,
                                  initialDate: DateTime.parse(
                                    response['date'] as String,
                                  ),
                                ),
                              ),
                            );
                            if (mounted && result == true) {
                              _refresh();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Lectures with some attendance already recorded are excluded. Existing marking-window rules still apply.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
