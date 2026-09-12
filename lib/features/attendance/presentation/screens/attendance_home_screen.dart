import 'package:flutter/material.dart';
import '../widgets/attendance_action_card.dart';
import '../widgets/attendance_summary_section.dart';
import '../widgets/defaulters_section.dart';
import 'mark_staff_attendance_screen.dart';
import 'staff_attendance_list_screen.dart';
import 'student_attendance_screen.dart';
import 'class_trends_screen.dart';
import 'teacher_trends_screen.dart';

enum _AnalyticsView { summary, defaulters }

class AttendanceHomeScreen extends StatefulWidget {
  const AttendanceHomeScreen({super.key});

  @override
  State<AttendanceHomeScreen> createState() => _AttendanceHomeScreenState();
}

class _AttendanceHomeScreenState extends State<AttendanceHomeScreen> {
  _AnalyticsView _view = _AnalyticsView.summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body:  SingleChildScrollView(
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
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const MarkStaffAttendanceScreen())),
            ),
            const SizedBox(width: 12),
            AttendanceActionCard(
              icon: Icons.fact_check_outlined,
              title: 'View Staff Attendance',
              description: 'Browse staff/teacher attendance by date',
              buttonLabel: 'View Now',
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const StaffAttendanceListScreen())),
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
              icon: Icons.pie_chart_outline_rounded,
              title: 'Class Trends',
              description: 'Attendance % breakdown for a class over a range',
              buttonLabel: 'View Trends',
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ClassTrendsScreen())),
            ),
            const SizedBox(width: 12),
            AttendanceActionCard(
              icon: Icons.insights_rounded,
              title: 'Teacher Trends',
              description: 'Student attendance in a teacher\'s classes over a range',
              buttonLabel: 'View Trends',
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const TeacherTrendsScreen())),
            ),
          ],
        ),
      ),
      const Divider(height: 1),
      const SizedBox(height: 16),
      Center(
        child: SegmentedButton<_AnalyticsView>(
          segments: const [
            ButtonSegment(
              value: _AnalyticsView.summary,
              label: Text('Summary'),
              icon: Icon(Icons.summarize_outlined),
            ),
            ButtonSegment(
              value: _AnalyticsView.defaulters,
              label: Text('Defaulters'),
              icon: Icon(Icons.warning_amber_rounded),
            ),
          ],
          selected: {_view},
          onSelectionChanged: (selection) => setState(() => _view = selection.first),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 500,
        child: _view == _AnalyticsView.summary
            ? const AttendanceSummarySection()
            : const DefaultersSection(),
      ),
      const SizedBox(height: 16),
    ],
  ),
),
    );
  }
}