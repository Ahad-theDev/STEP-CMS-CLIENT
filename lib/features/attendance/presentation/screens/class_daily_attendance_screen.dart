import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../data/models/student_daily_attendance_roster.dart';
import '../../data/models/morning_attendance_request.dart';
import '../../data/models/closing_attendance_request.dart';
import '../../application/daily_attendance_repository_provider.dart';
import '../../application/daily_attendance_roster_provider.dart';
import '../../application/submit_daily_attendance_controller.dart';

class ClassDailyAttendanceScreen extends ConsumerStatefulWidget {
  final SchoolClass? initialClass;
  final DateTime? initialDate;

  const ClassDailyAttendanceScreen({
    super.key,
    this.initialClass,
    this.initialDate,
  });

  @override
  ConsumerState<ClassDailyAttendanceScreen> createState() =>
      _ClassDailyAttendanceScreenState();
}

class _ClassDailyAttendanceScreenState
    extends ConsumerState<ClassDailyAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;
  SchoolClass? _selectedClass;

  // Local state for edits
  // Map of studentId -> status ('present', 'absent', 'late', 'leave')
  final Map<String, String> _morningSelections = {};
  // Map of studentId -> status ('present', 'absent')
  final Map<String, String> _closingSelections = {};
  // Map of studentId -> remarks
  final Map<String, String> _remarks = {};

  String _searchQuery = '';
  String? _morningFilter; // null = all, or 'present', 'absent', 'late', 'leave', 'unmarked'
  String? _closingFilter; // null = all, or 'present', 'absent', 'unmarked'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedClass = widget.initialClass;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _syncWithLoadedRoster(DailyClassRoster roster) {
    for (final s in roster.students) {
      if (s.morningStatus != null && !_morningSelections.containsKey(s.studentId)) {
        _morningSelections[s.studentId] = s.morningStatus!;
      }
      if (s.closingStatus != null && !_closingSelections.containsKey(s.studentId)) {
        _closingSelections[s.studentId] = s.closingStatus!;
      }
      if (s.remarks != null && !_remarks.containsKey(s.studentId)) {
        _remarks[s.studentId] = s.remarks!;
      }
    }
  }

  String _formatDateDisplay(DateTime d) {
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${d.day} ${months[d.month]} ${d.year}';
    return isToday ? 'Today, $dateStr' : dateStr;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _morningSelections.clear();
        _closingSelections.clear();
        _remarks.clear();
      });
    }
  }

  void _stepDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _morningSelections.clear();
      _closingSelections.clear();
      _remarks.clear();
    });
  }

  void _markAllMorningPresent(List<DailyRosterStudent> students) {
    setState(() {
      for (final s in students) {
        _morningSelections[s.studentId] = 'present';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All students set to Present for Morning Checkpoint'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markAllClosingPresent(List<DailyRosterStudent> students) {
    setState(() {
      for (final s in students) {
        // Only mark closing present if student was present or late in the morning
        final morning = _morningSelections[s.studentId] ?? s.morningStatus;
        if (morning == 'present' || morning == 'late') {
          _closingSelections[s.studentId] = 'present';
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All eligible morning students marked Present at Closing'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editRemarks(DailyRosterStudent student) async {
    final currentRemarks = _remarks[student.studentId] ?? student.remarks ?? '';
    final controller = TextEditingController(text: currentRemarks);

    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remarks: ${student.studentName}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 255,
          decoration: const InputDecoration(
            hintText: 'Enter reason or note (e.g., Sick leave, Early pass)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated != null) {
      setState(() {
        _remarks[student.studentId] = updated;
      });
    }
  }

  Future<void> _submitMorning(List<DailyRosterStudent> students) async {
    if (_selectedClass == null) return;

    final entries = <MorningAttendanceEntry>[];
    for (final s in students) {
      final status = _morningSelections[s.studentId] ?? s.morningStatus;
      if (status != null) {
        entries.add(
          MorningAttendanceEntry(
            studentId: s.studentId,
            status: status,
            remarks: _remarks[s.studentId] ?? s.remarks,
          ),
        );
      }
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark attendance for at least one student first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final dateStr =
        '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final request = MorningAttendanceRequest(
      attendanceDate: dateStr,
      entries: entries,
    );

    final notifier = ref.read(submitDailyAttendanceControllerProvider.notifier);
    final result = await notifier.submitMorning(
      classId: _selectedClass!.id,
      request: request,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${result.message} (${entries.length} students recorded)'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      // Refresh roster provider
      ref.invalidate(
        dailyAttendanceRosterProvider(
          DailyRosterQuery(classId: _selectedClass!.id, date: _selectedDate),
        ),
      );
    } else {
      final state = ref.read(submitDailyAttendanceControllerProvider);
      final errorMsg = state.hasError ? friendlyErrorMessage(state.error!) : 'Failed to save attendance';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ $errorMsg'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _submitClosing(List<DailyRosterStudent> students) async {
    if (_selectedClass == null) return;

    final entries = <ClosingAttendanceEntry>[];
    for (final s in students) {
      final status = _closingSelections[s.studentId] ?? s.closingStatus;
      if (status != null) {
        entries.add(
          ClosingAttendanceEntry(
            studentId: s.studentId,
            status: status,
            remarks: _remarks[s.studentId] ?? s.remarks,
          ),
        );
      }
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark closing status for students first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final dateStr =
        '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final request = ClosingAttendanceRequest(
      attendanceDate: dateStr,
      entries: entries,
    );

    final notifier = ref.read(submitDailyAttendanceControllerProvider.notifier);
    final result = await notifier.submitClosing(
      classId: _selectedClass!.id,
      request: request,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${result.message} (${entries.length} students updated)'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      ref.invalidate(
        dailyAttendanceRosterProvider(
          DailyRosterQuery(classId: _selectedClass!.id, date: _selectedDate),
        ),
      );
    } else {
      final state = ref.read(submitDailyAttendanceControllerProvider);
      final errorMsg = state.hasError ? friendlyErrorMessage(state.error!) : 'Failed to save closing attendance';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ $errorMsg'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  String _calculateProjectedFinalStatus(String? morning, String? closing) {
    if (morning == null) return 'Unmarked';
    if (morning == 'leave') return 'Leave';
    if (morning == 'late') return 'Late';
    if (morning == 'present') {
      if (closing == 'present') return 'Present';
      if (closing == 'absent') return 'Short Leave';
      return 'Pending Closing';
    }
    if (morning == 'absent') {
      if (closing == 'present') return 'Late';
      if (closing == 'absent') return 'Absent';
      return 'Pending Closing';
    }
    return 'Unknown';
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'present':
        return const Color(0xFF16A34A);
      case 'absent':
        return const Color(0xFFDC2626);
      case 'late':
        return const Color(0xFFD97706);
      case 'leave':
        return const Color(0xFF7C3AED);
      case 'short_leave':
      case 'Short Leave':
        return const Color(0xFFEA580C);
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  Color _getStatusBg(String? status) {
    switch (status) {
      case 'present':
        return const Color(0xFFDCFCE7);
      case 'absent':
        return const Color(0xFFFEE2E2);
      case 'late':
        return const Color(0xFFFEF3C7);
      case 'leave':
        return const Color(0xFFEDE9FE);
      case 'short_leave':
      case 'Short Leave':
        return const Color(0xFFFFEDD5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(dailyAttendanceClassesProvider);
    final submitState = ref.watch(submitDailyAttendanceControllerProvider);
    final isSubmitting = submitState.isLoading;

    return CampusPage(
      appBar: AppBar(
        title: const Text('Class In-Charge Attendance'),
        actions: [
          IconButton(
            tooltip: 'Refresh Roster',
            onPressed: () {
              ref.invalidate(dailyAttendanceClassesProvider);
              if (_selectedClass != null) {
                ref.invalidate(
                  dailyAttendanceRosterProvider(
                    DailyRosterQuery(
                      classId: _selectedClass!.id,
                      date: _selectedDate,
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.wb_sunny_rounded), text: 'Morning Checkpoint'),
            Tab(icon: Icon(Icons.nightlight_round), text: 'Closing Checkpoint'),
          ],
        ),
      ),
      body: CampusScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section: Class & Date Selection
            _buildSelectionHeader(classesAsync),
            const SizedBox(height: 20),

            if (_selectedClass == null)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: CampusStyle.card,
                child: const Column(
                  children: [
                    Icon(Icons.school_outlined, size: 48, color: CampusStyle.muted),
                    SizedBox(height: 12),
                    Text(
                      'Please select an assigned class to view and mark attendance.',
                      style: TextStyle(fontSize: 16, color: CampusStyle.muted),
                    ),
                  ],
                ),
              )
            else
              _buildRosterBody(isSubmitting),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionHeader(AsyncValue<List<SchoolClass>> classesAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CampusStyle.card,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: classesAsync.when(
                  data: (classes) {
                    final activeClasses =
                        classes.where((c) => c.isActive).toList();

                    if (activeClasses.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFFD97706)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You are not assigned as an in-charge for any class. Please contact management.',
                                style: TextStyle(
                                  color: Color(0xFF92400E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (_selectedClass == null && activeClasses.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _selectedClass == null) {
                          setState(() {
                            _selectedClass = activeClasses.first;
                          });
                        }
                      });
                    }

                    // If only 1 class is assigned (typical for in-charge teacher), show dedicated badge
                    if (activeClasses.length == 1) {
                      final singleClass = activeClasses.first;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.meeting_room_outlined, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'In-Charge Class: ${singleClass.name} (${singleClass.section})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Academic Year: ${singleClass.academicYear}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: CampusStyle.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ASSIGNED',
                                style: TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return DropdownButtonFormField<SchoolClass>(
                      isExpanded: true,
                      decoration: CampusStyle.input(
                        'Assigned Class',
                        Icons.meeting_room_outlined,
                      ),
                      value: _selectedClass != null &&
                              activeClasses.any((c) => c.id == _selectedClass!.id)
                          ? activeClasses.firstWhere((c) => c.id == _selectedClass!.id)
                          : null,
                      items: activeClasses.map((cls) {
                        return DropdownMenuItem<SchoolClass>(
                          value: cls,
                          child: Text(
                            'Class ${cls.name} (${cls.section})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedClass = val;
                            _morningSelections.clear();
                            _closingSelections.clear();
                            _remarks.clear();
                          });
                        }
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(
                    'Error loading classes: ${friendlyErrorMessage(e)}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date Selector Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Previous Day',
                  onPressed: () => _stepDate(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_note_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _formatDateDisplay(_selectedDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: CampusStyle.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Next Day',
                  onPressed: () => _stepDate(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterBody(bool isSubmitting) {
    final rosterAsync = ref.watch(
      dailyAttendanceRosterProvider(
        DailyRosterQuery(classId: _selectedClass!.id, date: _selectedDate),
      ),
    );

    return rosterAsync.when(
      data: (roster) {
        _syncWithLoadedRoster(roster);
        final allStudents = roster.students;

        if (allStudents.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: CampusStyle.card,
            child: const Text(
              'No active students found in this class.',
              style: TextStyle(color: CampusStyle.muted),
            ),
          );
        }

        return Column(
          children: [
            // Stats & Metrics summary bar
            _buildStatsOverview(allStudents),
            const SizedBox(height: 16),

            // Tab Views: Morning vs Closing
            SizedBox(
              height: 600,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMorningTab(allStudents, isSubmitting),
                  _buildClosingTab(allStudents, isSubmitting),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(24),
        decoration: CampusStyle.card,
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Failed to load class roster:\n${friendlyErrorMessage(e)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(
                dailyAttendanceRosterProvider(
                  DailyRosterQuery(
                    classId: _selectedClass!.id,
                    date: _selectedDate,
                  ),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(List<DailyRosterStudent> students) {
    int morningMarked = 0;
    int closingMarked = 0;
    int morningPresent = 0;
    int morningAbsent = 0;

    for (final s in students) {
      final m = _morningSelections[s.studentId] ?? s.morningStatus;
      final c = _closingSelections[s.studentId] ?? s.closingStatus;
      if (m != null) {
        morningMarked++;
        if (m == 'present' || m == 'late') morningPresent++;
        if (m == 'absent') morningAbsent++;
      }
      if (c != null) closingMarked++;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', '${students.length}', Icons.groups),
          _statItem(
            'Morning Check',
            '$morningMarked/${students.length}',
            Icons.wb_sunny_outlined,
            color: morningMarked == students.length ? Colors.green : Colors.amber.shade800,
          ),
          _statItem(
            'Present',
            '$morningPresent',
            Icons.check_circle_outline,
            color: const Color(0xFF16A34A),
          ),
          _statItem(
            'Absent',
            '$morningAbsent',
            Icons.cancel_outlined,
            color: const Color(0xFFDC2626),
          ),
          _statItem(
            'Closing Check',
            '$closingMarked/${students.length}',
            Icons.nightlight_outlined,
            color: closingMarked == students.length ? Colors.green : Colors.amber.shade800,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? CampusStyle.ink,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: CampusStyle.muted),
        ),
      ],
    );
  }

  // =========================================================================
  // Tab 1: Morning Checkpoint
  // =========================================================================
  Widget _buildMorningTab(List<DailyRosterStudent> students, bool isSubmitting) {
    final filtered = students.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      final current = _morningSelections[s.studentId] ?? s.morningStatus;
      if (_morningFilter == null) return true;
      if (_morningFilter == 'unmarked') return current == null;
      return current == _morningFilter;
    }).toList();

    return Column(
      children: [
        // Controls Row: Mark All Present + Filter Chips
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by student name or roll number...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                ),
                onPressed: () => _markAllMorningPresent(students),
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('Mark All Present'),
              ),
            ],
          ),
        ),

        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              _filterChip('All', null, _morningFilter, (v) => setState(() => _morningFilter = v)),
              const SizedBox(width: 6),
              _filterChip('Unmarked', 'unmarked', _morningFilter, (v) => setState(() => _morningFilter = v)),
              const SizedBox(width: 6),
              _filterChip('Present', 'present', _morningFilter, (v) => setState(() => _morningFilter = v)),
              const SizedBox(width: 6),
              _filterChip('Absent', 'absent', _morningFilter, (v) => setState(() => _morningFilter = v)),
              const SizedBox(width: 6),
              _filterChip('Late', 'late', _morningFilter, (v) => setState(() => _morningFilter = v)),
              const SizedBox(width: 6),
              _filterChip('Leave', 'leave', _morningFilter, (v) => setState(() => _morningFilter = v)),
            ],
          ),
        ),

        // Students List
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = filtered[index];
              final currentStatus =
                  _morningSelections[student.studentId] ?? student.morningStatus;
              final remark =
                  _remarks[student.studentId] ?? student.remarks;

              return _buildMorningStudentTile(
                student: student,
                selectedStatus: currentStatus,
                remark: remark,
                onStatusChanged: (status) {
                  setState(() {
                    _morningSelections[student.studentId] = status;
                  });
                },
                onEditRemarks: () => _editRemarks(student),
              );
            },
          ),
        ),

        // Bottom Action Bar: Save Morning Attendance
        Container(
          padding: const EdgeInsets.only(top: 14),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: isSubmitting ? null : () => _submitMorning(students),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                isSubmitting
                    ? 'Saving Morning Attendance...'
                    : 'Save Morning Attendance (${_morningSelections.length} marked)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMorningStudentTile({
    required DailyRosterStudent student,
    required String? selectedStatus,
    required String? remark,
    required ValueChanged<String> onStatusChanged,
    required VoidCallback onEditRemarks,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedStatus != null
              ? _getStatusColor(selectedStatus).withValues(alpha: 0.4)
              : const Color(0xFFE2E8F0),
          width: selectedStatus != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  student.rollNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: CampusStyle.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  student.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                tooltip: remark != null && remark.isNotEmpty
                    ? 'Remark: $remark'
                    : 'Add Remark',
                icon: Icon(
                  remark != null && remark.isNotEmpty
                      ? Icons.comment_rounded
                      : Icons.add_comment_outlined,
                  size: 20,
                  color: remark != null && remark.isNotEmpty
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                onPressed: onEditRemarks,
              ),
            ],
          ),
          if (remark != null && remark.isNotEmpty) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Note: $remark',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: CampusStyle.muted,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          // 4 Status choices
          Row(
            children: [
              _statusButton('Present', 'present', selectedStatus, onStatusChanged),
              const SizedBox(width: 6),
              _statusButton('Absent', 'absent', selectedStatus, onStatusChanged),
              const SizedBox(width: 6),
              _statusButton('Late', 'late', selectedStatus, onStatusChanged),
              const SizedBox(width: 6),
              _statusButton('Leave', 'leave', selectedStatus, onStatusChanged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(
    String label,
    String value,
    String? current,
    ValueChanged<String> onSelect,
  ) {
    final isSelected = current == value;
    final color = _getStatusColor(value);
    final bg = _getStatusBg(value);

    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? bg : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFCBD5E1),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : CampusStyle.ink,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // Tab 2: Closing Checkpoint
  // =========================================================================
  Widget _buildClosingTab(List<DailyRosterStudent> students, bool isSubmitting) {
    // Check how many students have morning attendance saved
    final missingMorning = students
        .where((s) => (_morningSelections[s.studentId] ?? s.morningStatus) == null)
        .length;

    final filtered = students.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      final current = _closingSelections[s.studentId] ?? s.closingStatus;
      if (_closingFilter == null) return true;
      if (_closingFilter == 'unmarked') return current == null;
      return current == _closingFilter;
    }).toList();

    return Column(
      children: [
        if (missingMorning > 0)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFB45309)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ Note: $missingMorning student(s) do not have morning attendance marked yet. '
                    'Morning checkpoint must be saved before closing attendance can be accepted.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Controls Row
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Mark if student stayed until dismissal or left early:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CampusStyle.muted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _markAllClosingPresent(students),
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text('Mark Eligible Present'),
              ),
            ],
          ),
        ),

        // Students List for Closing
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = filtered[index];
              final morningStatus =
                  _morningSelections[student.studentId] ?? student.morningStatus;
              final closingStatus =
                  _closingSelections[student.studentId] ?? student.closingStatus;
              final remark =
                  _remarks[student.studentId] ?? student.remarks;

              return _buildClosingStudentTile(
                student: student,
                morningStatus: morningStatus,
                closingStatus: closingStatus,
                remark: remark,
                onClosingChanged: (status) {
                  setState(() {
                    _closingSelections[student.studentId] = status;
                  });
                },
                onEditRemarks: () => _editRemarks(student),
              );
            },
          ),
        ),

        // Bottom Action Bar: Save Closing Attendance
        Container(
          padding: const EdgeInsets.only(top: 14),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
              ),
              onPressed: isSubmitting ? null : () => _submitClosing(students),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                isSubmitting
                    ? 'Saving Closing Attendance...'
                    : 'Save Closing Attendance (${_closingSelections.length} marked)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClosingStudentTile({
    required DailyRosterStudent student,
    required String? morningStatus,
    required String? closingStatus,
    required String? remark,
    required ValueChanged<String> onClosingChanged,
    required VoidCallback onEditRemarks,
  }) {
    final projectedFinal = _calculateProjectedFinalStatus(morningStatus, closingStatus);
    final isMorningAbsentOrLeave =
        morningStatus == 'absent' || morningStatus == 'leave';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: closingStatus != null
              ? _getStatusColor(closingStatus).withValues(alpha: 0.4)
              : const Color(0xFFE2E8F0),
          width: closingStatus != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  student.rollNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  student.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              // Morning Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBg(morningStatus),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getStatusColor(morningStatus).withValues(alpha: 0.5)),
                ),
                child: Text(
                  morningStatus != null
                      ? '☀️ Morning: ${morningStatus.toUpperCase()}'
                      : '☀️ Morning: Unmarked',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(morningStatus),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Add / Edit Remark',
                icon: Icon(
                  remark != null && remark.isNotEmpty
                      ? Icons.comment_rounded
                      : Icons.add_comment_outlined,
                  size: 20,
                  color: remark != null && remark.isNotEmpty
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                onPressed: onEditRemarks,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Closing Options
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: _closingOption(
                        label: 'Present (Stayed)',
                        value: 'present',
                        current: closingStatus,
                        isDisabled: isMorningAbsentOrLeave,
                        onSelect: onClosingChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _closingOption(
                        label: 'Absent (Early Off)',
                        value: 'absent',
                        current: closingStatus,
                        isDisabled: isMorningAbsentOrLeave,
                        onSelect: onClosingChanged,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Final Projected Status Badge
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getStatusBg(projectedFinal),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(projectedFinal).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Result: $projectedFinal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(projectedFinal),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _closingOption({
    required String label,
    required String value,
    required String? current,
    required bool isDisabled,
    required ValueChanged<String> onSelect,
  }) {
    final isSelected = current == value;
    final color = value == 'present'
        ? const Color(0xFF16A34A)
        : const Color(0xFFEA580C);

    return InkWell(
      onTap: isDisabled ? null : () => onSelect(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : (isDisabled ? const Color(0xFFF1F5F9) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color
                : (isDisabled ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1)),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isDisabled
                ? Colors.grey
                : (isSelected ? color : CampusStyle.ink),
          ),
        ),
      ),
    );
  }

  Widget _filterChip(
    String label,
    String? value,
    String? selectedValue,
    ValueChanged<String?> onSelect,
  ) {
    final isSelected = selectedValue == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(value),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
