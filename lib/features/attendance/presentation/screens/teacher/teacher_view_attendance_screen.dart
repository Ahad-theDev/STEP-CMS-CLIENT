import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/network/dio_client.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../../application/student_attendance_repository_provider.dart';

final _optionsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final response = await ref
      .watch(dioProvider)
      .get('/attendance/students/filter-options');
  return Map<String, dynamic>.from(response.data);
});

class TeacherViewAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherViewAttendanceScreen({super.key});
  @override
  ConsumerState<TeacherViewAttendanceScreen> createState() =>
      _TeacherViewAttendanceScreenState();
}

class _TeacherViewAttendanceScreenState
    extends ConsumerState<TeacherViewAttendanceScreen> {
  String? _classId, _lectureId, _studentId, _status;
  DateTime? _date = DateUtils.dateOnly(DateTime.now());
  DateTimeRange _range = DateTimeRange(
    start: DateUtils.dateOnly(
      DateTime.now().subtract(const Duration(days: 30)),
    ),
    end: DateUtils.dateOnly(DateTime.now()),
  );
  bool _summary = false;
  late Future<List<dynamic>> _results;
  @override
  void initState() {
    super.initState();
    _results = Future.value([]);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  void _load() {
    final repo = ref.read(studentAttendanceRepositoryProvider);
    setState(() {
      _results = _summary
          ? (_classId == null
                ? Future.value([])
                : repo.getSummary(
                    classId: _classId!,
                    dateFrom: _range.start,
                    dateTo: _range.end,
                  ))
          : repo.listAttendance(
              classId: _classId,
              lectureId: _lectureId,
              studentId: _studentId,
              status: _status,
              date: _date,
            );
    });
  }

  Widget _dropdown(
    String label,
    String? value,
    List<dynamic> options,
    ValueChanged<String?> changed,
  ) => DropdownButtonFormField<String>(
    key: ValueKey('$label:$value'),
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      DropdownMenuItem<String>(
        value: null,
        child: Text('All ${label.toLowerCase()}'),
      ),
      ...options.map(
        (o) => DropdownMenuItem<String>(
          value: o['id'] as String,
          child: Text(o['label'] as String, overflow: TextOverflow.ellipsis),
        ),
      ),
    ],
    onChanged: changed,
  );
  @override
  Widget build(BuildContext context) => CampusPage(
    appBar: AppBar(
      title: const Text('View Attendance'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.invalidate(_optionsProvider);
            _load();
          },
        ),
      ],
    ),
    body: CampusScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CampusSectionIntro(
            title: 'Your class attendance',
            subtitle:
                'Review student records or a class summary for your own lectures.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            children: [
              ChoiceChip(
                label: const Text('Records'),
                selected: !_summary,
                onSelected: (_) {
                  setState(() => _summary = false);
                  _load();
                },
              ),
              ChoiceChip(
                label: const Text('Class summary'),
                selected: _summary,
                onSelected: (_) {
                  setState(() => _summary = true);
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ref
              .watch(_optionsProvider)
              .when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Column(
                  children: [
                    Text(friendlyErrorMessage(e)),
                    TextButton(
                      onPressed: () => ref.invalidate(_optionsProvider),
                      child: const Text('Retry filters'),
                    ),
                  ],
                ),
                data: (options) => Column(
                  children: [
                    _dropdown('Classes', _classId, options['classes'] as List, (
                      v,
                    ) {
                      setState(() {
                        _classId = v;
                        _lectureId = null;
                        _studentId = null;
                      });
                      _load();
                    }),
                    if (!_summary) ...[
                      const SizedBox(height: 12),
                      _dropdown(
                        'Lectures',
                        _lectureId,
                        (options['lectures'] as List)
                            .where(
                              (o) =>
                                  _classId == null || o['class_id'] == _classId,
                            )
                            .toList(),
                        (v) {
                          setState(() => _lectureId = v);
                          _load();
                        },
                      ),
                      const SizedBox(height: 12),
                      _dropdown(
                        'Students',
                        _studentId,
                        (options['students'] as List)
                            .where(
                              (o) =>
                                  _classId == null || o['class_id'] == _classId,
                            )
                            .toList(),
                        (v) {
                          setState(() => _studentId = v);
                          _load();
                        },
                      ),
                      const SizedBox(height: 12),
                      _dropdown(
                        'Statuses',
                        _status,
                        [
                          for (final s in [
                            'present',
                            'absent',
                            'late',
                            'leave',
                          ])
                            {
                              'id': s,
                              'label': '${s[0].toUpperCase()}${s.substring(1)}',
                            },
                        ],
                        (v) {
                          setState(() => _status = v);
                          _load();
                        },
                      ),
                    ],
                  ],
                ),
              ),
          const SizedBox(height: 12),
          if (_summary)
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text('${_fmt(_range.start)} to ${_fmt(_range.end)}'),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDateRange: _range,
                );
                if (picked != null && mounted) {
                  setState(() => _range = picked);
                  _load();
                }
              },
            )
          else
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_date == null ? 'All dates' : _fmt(_date!)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && mounted) {
                      setState(() => _date = picked);
                      _load();
                    }
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _date = null);
                    _load();
                  },
                  child: const Text('All dates'),
                ),
              ],
            ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _summary && _classId == null ? null : _load,
            icon: const Icon(Icons.search),
            label: const Text('Show attendance'),
          ),
          const SizedBox(height: 20),
          if (_summary && _classId == null)
            const Text('Select a class to view its summary.')
          else
            FutureBuilder<List<dynamic>>(
              future: _results,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      Text(friendlyErrorMessage(snapshot.error!)),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Text(
                    'No attendance records for these filters. Choose filters and tap Show attendance.',
                  );
                }
                return Column(
                  children: items
                      .map(
                        (r) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(r.studentName as String),
                            subtitle: _summary
                                ? Text(
                                    'Present: ${r.presentCount} • Absent: ${r.absentCount}\nLate: ${r.lateCount} • Leave: ${r.leaveCount}\nTotal: ${r.totalLectures} • Attendance: ${r.percentagePresent.toStringAsFixed(1)}%',
                                  )
                                : Text(
                                    '${r.date} • ${r.status}\n${r.remarks ?? ''}',
                                  ),
                            isThreeLine: true,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    ),
  );
}
