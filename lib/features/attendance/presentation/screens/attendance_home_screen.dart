import 'package:flutter/material.dart';
import '../widgets/attendance_action_card.dart';
import '../widgets/class_trends_section.dart';
import '../widgets/teacher_trends_section.dart';
import 'mark_staff_attendance_screen.dart';
import 'staff_attendance_list_screen.dart';
import 'student_attendance_screen.dart';
import 'attendance_summary_screen.dart';
import 'defaulters_screen.dart';

enum _TrendsView { classTrends, teacherTrends }

class AttendanceHomeScreen extends StatefulWidget {
  const AttendanceHomeScreen({super.key});

  @override
  State<AttendanceHomeScreen> createState() => _AttendanceHomeScreenState();
}

class _AttendanceHomeScreenState extends State<AttendanceHomeScreen> {
  _TrendsView _view = _TrendsView.classTrends;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  AttendanceActionCard(
                    icon: Icons.how_to_reg_rounded,
                    title: 'Mark Staff Attendance',
                    description: 'Mark a staff member or teacher present/absent',
                    buttonLabel: 'Mark Now',
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MarkStaffAttendanceScreen())),
                  ),
                  const SizedBox(width: 12),
                  AttendanceActionCard(
                    icon: Icons.fact_check_outlined,
                    title: 'View Staff Attendance',
                    description: 'Browse staff/teacher attendance by date',
                    buttonLabel: 'View Now',
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StaffAttendanceListScreen())),
                  ),
                  const SizedBox(width: 12),
                  AttendanceActionCard(
                    icon: Icons.groups_outlined,
                    title: 'Student Attendance',
                    description: 'View and correct student attendance records',
                    buttonLabel: 'Open',
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const StudentAttendanceScreen())),
                  ),
                  const SizedBox(width: 12),
                  AttendanceActionCard(
                    icon: Icons.summarize_outlined,
                    title: 'Attendance Summary',
                    description: 'Per-student attendance % over a date range',
                    buttonLabel: 'View Summary',
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const AttendanceSummaryScreen())),
                  ),
                  const SizedBox(width: 12),
                  AttendanceActionCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Defaulters',
                    description: 'Students below an attendance % threshold',
                    buttonLabel: 'View List',
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const DefaultersScreen())),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Center(
              child: SegmentedButton<_TrendsView>(
                segments: const [
                  ButtonSegment(
                    value: _TrendsView.classTrends,
                    label: Text('Class Trends'),
                    icon: Icon(Icons.pie_chart_outline_rounded),
                  ),
                  ButtonSegment(
                    value: _TrendsView.teacherTrends,
                    label: Text('Teacher Trends'),
                    icon: Icon(Icons.insights_rounded),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (selection) => setState(() => _view = selection.first),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 500,
              child: _view == _TrendsView.classTrends
                  ? const ClassTrendsSection()
                  : const TeacherTrendsSection(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}