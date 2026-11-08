import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import '../../data/models/student_daily_attendance_roster.dart';
import '../../data/models/daily_attendance_correction_request.dart';
import '../../application/daily_attendance_repository_provider.dart';
import '../../application/daily_attendance_roster_provider.dart';
import '../../application/submit_daily_attendance_controller.dart';

class AdminDailyAttendanceScreen extends ConsumerStatefulWidget {
  final SchoolClass? initialClass;
  final DateTime? initialDate;

  const AdminDailyAttendanceScreen({
    super.key,
    this.initialClass,
    this.initialDate,
  });

  @override
  ConsumerState<AdminDailyAttendanceScreen> createState() =>
      _AdminDailyAttendanceScreenState();
}

class _AdminDailyAttendanceScreenState
    extends ConsumerState<AdminDailyAttendanceScreen> {
  late DateTime _selectedDate;
  SchoolClass? _selectedClass;
  String _searchQuery = '';
  String? _statusFilter; // null = all, or 'present', 'absent', 'late', 'short_leave', 'leave', 'unmarked'

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedClass = widget.initialClass;
  }

  String _formatDateDisplay(DateTime d) {
    final now = DateTime.now();
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
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
      setState(() => _selectedDate = picked);
    }
  }

  void _stepDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return const Color(0xFF16A34A);
      case 'absent':
        return const Color(0xFFDC2626);
      case 'late':
        return const Color(0xFFD97706);
      case 'leave':
        return const Color(0xFF7C3AED);
      case 'short_leave':
        return const Color(0xFFEA580C);
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  Color _getStatusBg(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return const Color(0xFFDCFCE7);
      case 'absent':
        return const Color(0xFFFEE2E2);
      case 'late':
        return const Color(0xFFFEF3C7);
      case 'leave':
        return const Color(0xFFEDE9FE);
      case 'short_leave':
        return const Color(0xFFFFEDD5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  String _formatStatusLabel(String? status) {
    if (status == null || status.isEmpty) return 'Unmarked';
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      case 'leave':
        return 'Leave';
      case 'short_leave':
        return 'Short Leave';
      default:
        return status;
    }
  }

  Future<void> _openCorrectionModal(DailyRosterStudent student) async {
    if (_selectedClass == null) return;

    final formKey = GlobalKey<FormState>();
    String? newMorning = student.morningStatus;
    String? newClosing = student.closingStatus;
    final remarksController = TextEditingController(text: student.remarks ?? '');
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Correct Attendance: ${student.studentName}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          'Roll #: ${student.rollNumber}  |  Current Final: ${_formatStatusLabel(student.finalStatus)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: CampusStyle.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Morning Checkpoint Correction
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Morning Checkpoint',
                          prefixIcon: Icon(Icons.wb_sunny_outlined, size: 20),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: newMorning,
                        items: const [
                          DropdownMenuItem(
                            value: 'present',
                            child: Text('Present'),
                          ),
                          DropdownMenuItem(
                            value: 'absent',
                            child: Text('Absent'),
                          ),
                          DropdownMenuItem(
                            value: 'late',
                            child: Text('Late'),
                          ),
                          DropdownMenuItem(
                            value: 'leave',
                            child: Text('Leave'),
                          ),
                        ],
                        onChanged: (val) {
                          setModalState(() => newMorning = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Closing Checkpoint Correction
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Closing Checkpoint',
                          prefixIcon: Icon(Icons.nightlight_outlined, size: 20),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: newClosing,
                        items: const [
                          DropdownMenuItem(
                            value: 'present',
                            child: Text('Present (Stayed)'),
                          ),
                          DropdownMenuItem(
                            value: 'absent',
                            child: Text('Absent (Left Early)'),
                          ),
                        ],
                        onChanged: (val) {
                          setModalState(() => newClosing = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Remarks
                      TextField(
                        controller: remarksController,
                        maxLength: 255,
                        decoration: const InputDecoration(
                          labelText: 'Remarks / Notes',
                          prefixIcon: Icon(Icons.notes_rounded, size: 20),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Audit Reason (Mandatory)
                      TextFormField(
                        controller: reasonController,
                        maxLines: 2,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Reason for Correction *',
                          hintText: 'e.g. Doctor slip provided / Gate pass verified',
                          prefixIcon: Icon(Icons.security_rounded, size: 20),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Correction reason is required for audit logs';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) return;

                  final hasChanged = newMorning != student.morningStatus ||
                      newClosing != student.closingStatus ||
                      remarksController.text.trim() != (student.remarks ?? '');

                  if (!hasChanged) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No changes were made to attendance.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final dateStr =
                      '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
                  final request = DailyAttendanceCorrectionRequest(
                    attendanceDate: dateStr,
                    morningStatus: newMorning,
                    closingStatus: newClosing,
                    remarks: remarksController.text.trim().isEmpty
                        ? null
                        : remarksController.text.trim(),
                    reason: reasonController.text.trim(),
                  );

                  final notifier = ref.read(
                    submitDailyAttendanceControllerProvider.notifier,
                  );
                  final success = await notifier.correctAttendance(
                    classId: _selectedClass!.id,
                    studentId: student.studentId,
                    request: request,
                  );

                  if (context.mounted) {
                    Navigator.of(ctx).pop(success);
                  }
                },
                child: const Text('Apply Correction'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Daily attendance corrected and audit log recorded.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      ref.invalidate(
        dailyAttendanceRosterProvider(
          DailyRosterQuery(classId: _selectedClass!.id, date: _selectedDate),
        ),
      );
    } else if (result == false && mounted) {
      final state = ref.read(submitDailyAttendanceControllerProvider);
      final errorMsg = state.hasError
          ? friendlyErrorMessage(state.error!)
          : 'Failed to correct attendance';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ $errorMsg'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(dailyAttendanceClassesProvider);

    return CampusPage(
      appBar: AppBar(
        title: const Text('Daily Attendance Review'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
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
      ),
      body: CampusScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CampusSectionIntro(
              title: 'Daily Class Attendance Oversight',
              subtitle:
                  'Review morning arrival and closing dismissal records with audit correction capability.',
            ),
            const SizedBox(height: 20),

            // Class and Date controls
            _buildSelectionHeader(classesAsync),
            const SizedBox(height: 20),

            if (_selectedClass == null)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: CampusStyle.card,
                child: const Text(
                  'Select a class to review daily attendance.',
                  style: TextStyle(color: CampusStyle.muted),
                ),
              )
            else
              _buildClassRosterView(),
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
                    if (_selectedClass == null && activeClasses.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _selectedClass == null) {
                          setState(() => _selectedClass = activeClasses.first);
                        }
                      });
                    }

                    return DropdownButtonFormField<SchoolClass>(
                      isExpanded: true,
                      decoration: CampusStyle.input(
                        'Select Class',
                        Icons.school_outlined,
                      ),
                      value: _selectedClass != null &&
                              activeClasses.any((c) => c.id == _selectedClass!.id)
                          ? activeClasses
                              .firstWhere((c) => c.id == _selectedClass!.id)
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
                          setState(() => _selectedClass = val);
                        }
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(
                    'Error: ${friendlyErrorMessage(e)}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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

  Widget _buildClassRosterView() {
    final rosterAsync = ref.watch(
      dailyAttendanceRosterProvider(
        DailyRosterQuery(classId: _selectedClass!.id, date: _selectedDate),
      ),
    );

    return rosterAsync.when(
      data: (roster) {
        final students = roster.students;
        if (students.isEmpty) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Row
            _buildOverviewStats(students),
            const SizedBox(height: 16),

            // Search & Filter
            _buildSearchAndFilters(),
            const SizedBox(height: 14),

            // Students List
            _buildStudentsList(students),
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
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStats(List<DailyRosterStudent> students) {
    int present = 0;
    int absent = 0;
    int lateCount = 0;
    int shortLeave = 0;
    int leave = 0;
    int unmarked = 0;

    for (final s in students) {
      final f = s.finalStatus?.toLowerCase();
      if (f == 'present') {
        present++;
      } else if (f == 'absent') {
        absent++;
      } else if (f == 'late') {
        lateCount++;
      } else if (f == 'short_leave') {
        shortLeave++;
      } else if (f == 'leave') {
        leave++;
      } else {
        unmarked++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceAround,
        children: [
          _statBadge('Total', '${students.length}', AppColors.onSurfaceVariant),
          _statBadge('Present', '$present', const Color(0xFF16A34A)),
          _statBadge('Absent', '$absent', const Color(0xFFDC2626)),
          _statBadge('Late', '$lateCount', const Color(0xFFD97706)),
          _statBadge('Short Leave', '$shortLeave', const Color(0xFFEA580C)),
          _statBadge('Leave', '$leave', const Color(0xFF7C3AED)),
          if (unmarked > 0)
            _statBadge('Pending', '$unmarked', AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _statBadge(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: CampusStyle.muted),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search by student name or roll number...',
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All', null),
              const SizedBox(width: 6),
              _filterChip('Present', 'present'),
              const SizedBox(width: 6),
              _filterChip('Absent', 'absent'),
              const SizedBox(width: 6),
              _filterChip('Late', 'late'),
              const SizedBox(width: 6),
              _filterChip('Short Leave', 'short_leave'),
              const SizedBox(width: 6),
              _filterChip('Leave', 'leave'),
              const SizedBox(width: 6),
              _filterChip('Unmarked', 'unmarked'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String? value) {
    final isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _statusFilter = value),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStudentsList(List<DailyRosterStudent> allStudents) {
    final filtered = allStudents.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_statusFilter == null) return true;
      if (_statusFilter == 'unmarked') {
        return s.finalStatus == null || s.finalStatus!.isEmpty;
      }
      return s.finalStatus?.toLowerCase() == _statusFilter;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: const Text(
          'No students match the current filters.',
          style: TextStyle(color: CampusStyle.muted),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final s = filtered[index];
        return _buildStudentCard(s);
      },
    );
  }

  Widget _buildStudentCard(DailyRosterStudent s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Roll Number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              s.rollNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: CampusStyle.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Remarks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (s.remarks != null && s.remarks!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Note: ${s.remarks}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: CampusStyle.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Checkpoints: Morning & Closing
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _checkpointBadge('☀️ Morning', s.morningStatus),
              _checkpointBadge('🌙 Closing', s.closingStatus),
            ],
          ),
          const SizedBox(width: 10),

          // Final Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusBg(s.finalStatus),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor(s.finalStatus).withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              _formatStatusLabel(s.finalStatus),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(s.finalStatus),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Audit Correction Action Button
          IconButton(
            tooltip: 'Audit & Correct Attendance',
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
            onPressed: () => _openCorrectionModal(s),
          ),
        ],
      ),
    );
  }

  Widget _checkpointBadge(String title, String? status) {
    final hasMark = status != null && status.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: hasMark ? _getStatusBg(status) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$title: ${hasMark ? status.toUpperCase() : '-'}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: hasMark ? _getStatusColor(status) : CampusStyle.muted,
        ),
      ),
    );
  }
}
