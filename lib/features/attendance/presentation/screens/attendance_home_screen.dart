import 'package:flutter/material.dart';
import '../widgets/attendance_action_card.dart';
import 'mark_staff_attendance_screen.dart';
import 'staff_attendance_list_screen.dart';
import 'student_attendance_screen.dart';
import 'class_trends_screen.dart';
import 'teacher_trends_screen.dart';
import 'attendance_summary_screen.dart';
import 'defaulters_screen.dart';

class AttendanceHomeScreen extends StatelessWidget {
  const AttendanceHomeScreen({super.key});

  // Colors inspired by student management screen
  static const Color _markStaffBg = Color(0xFFE3F4F6);
  static const Color _markStaffIcon = Color(0xFF0795A5);
  static const Color _markStaffBtn = Color(0xFF0795A5);

  static const Color _viewStaffBg = Color(0xFFF6FBFF);
  static const Color _viewStaffIcon = Color(0xFF1769D1);
  static const Color _viewStaffBtn = Color(0xFF1265D4);

  static const Color _studentAttBg = Color(0xFFFFFFFA);
  static const Color _studentAttIcon = Color(0xFFF0A020);
  static const Color _studentAttBtn = Color(0xFFF5A018);

  static const Color _classTrendsBg = Color(0xFFF3E9E8);
  static const Color _classTrendsIcon = Color(0xFFE84245);
  static const Color _classTrendsBtn = Color(0xFFED4043);

  static const Color _teacherTrendsBg = Color(0xFFEAE8F4);
  static const Color _teacherTrendsIcon = Color(0xFF7941C4);
  static const Color _teacherTrendsBtn = Color(0xFF7335C5);

  static const Color _attendanceSummBg = Color(0xFFE8F5E9);
  static const Color _attendanceSummIcon = Color(0xFF43A047);
  static const Color _attendanceSummBtn = Color(0xFF388E3C);

  static const Color _defaultersBg = Color(0xFFFFF8E1);
  static const Color _defaultersIcon = Color(0xFFF5B041);
  static const Color _defaultersBtn = Color(0xFFEF6B73);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AttendanceActionCard(
                icon: Icons.how_to_reg_rounded,
                title: 'Mark Staff Attendance',
                description: 'Mark a staff member or teacher present/absent',
                buttonLabel: 'Mark Now',
                backgroundColor: _markStaffBg,
                iconColor: _markStaffIcon,
                buttonColor: _markStaffBtn,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const MarkStaffAttendanceScreen())),
              ),
              AttendanceActionCard(
                icon: Icons.fact_check_outlined,
                title: 'View Staff Attendance',
                description: 'Browse staff/teacher attendance by date',
                buttonLabel: 'View Now',
                backgroundColor: _viewStaffBg,
                iconColor: _viewStaffIcon,
                buttonColor: _viewStaffBtn,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const StaffAttendanceListScreen())),
              ),
              AttendanceActionCard(
                icon: Icons.groups_outlined,
                title: 'Student Attendance',
                description: 'View and correct student attendance records',
                buttonLabel: 'Open',
                backgroundColor: _studentAttBg,
                iconColor: _studentAttIcon,
                buttonColor: _studentAttBtn,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const StudentAttendanceScreen())),
              ),
              AttendanceActionCard(
                icon: Icons.pie_chart_outline_rounded,
                title: 'Class Trends',
                description: 'Attendance % breakdown for a class over a range',
                buttonLabel: 'View Trends',
                backgroundColor: _classTrendsBg,
                iconColor: _classTrendsIcon,
                buttonColor: _classTrendsBtn,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ClassTrendsScreen())),
              ),
              AttendanceActionCard(
                icon: Icons.insights_rounded,
                title: 'Teacher Trends',
                description: 'Student attendance in a teacher\'s classes over a range',
                buttonLabel: 'View Trends',
                backgroundColor: _teacherTrendsBg,
                iconColor: _teacherTrendsIcon,
                buttonColor: _teacherTrendsBtn,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const TeacherTrendsScreen())),
              ),
              AttendanceActionCard(
                icon: Icons.summarize_outlined,
                title: 'Attendance Summary',
                description: 'Per-student attendance % over a date range',
                buttonLabel: 'View Summary',
                backgroundColor: _attendanceSummBg,
                iconColor: _attendanceSummIcon,
                buttonColor: _attendanceSummBtn,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const AttendanceSummaryScreen())),
              ),
              AttendanceActionCard(
                icon: Icons.warning_amber_rounded,
                title: 'Defaulters',
                description: 'Students below an attendance % threshold',
                buttonLabel: 'View List',
                backgroundColor: _defaultersBg,
                iconColor: _defaultersIcon,
                buttonColor: _defaultersBtn,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const DefaultersScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}