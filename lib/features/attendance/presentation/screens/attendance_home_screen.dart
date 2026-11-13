import 'package:cms/core/theme/campus_style.dart';
import 'package:flutter/material.dart';
import '../widgets/attendance_action_card.dart';
import '../widgets/class_trends_section.dart';
import '../widgets/teacher_trends_section.dart';
import 'mark_staff_attendance_screen.dart';
import 'staff_attendance_list_screen.dart';
import 'student_attendance_screen.dart';
import 'attendance_summary_screen.dart';
import 'defaulters_screen.dart';
import 'admin_daily_attendance_screen.dart';
import 'class_daily_attendance_screen.dart';
import 'attendance_devices_screen.dart';
import 'teacher_enrollment_screen.dart';
import 'attendance_policy_screen.dart';
import 'teacher_kiosk_screen.dart';

enum _TrendsView { classTrends, teacherTrends }

class AttendanceHomeScreen extends StatefulWidget {
  final bool isPrincipalReadOnly;

  const AttendanceHomeScreen({super.key, this.isPrincipalReadOnly = false});

  @override
  State<AttendanceHomeScreen> createState() => _AttendanceHomeScreenState();
}

class _AttendanceHomeScreenState extends State<AttendanceHomeScreen> {
  _TrendsView _view = _TrendsView.classTrends;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: const Color(0xFFF5DCD7),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: CampusBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width < 480 ? 16 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1192),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF782323), Color(0xFFA63A33)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.fact_check_outlined,
                              color: Color(0xFFDBE7FF),
                              size: 30,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Every day counts.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Manage attendance, review records, and follow trends across your campus.',
                              style: TextStyle(
                                color: Color(0xFFE2E6FF),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Attendance workspace',
                        style: TextStyle(
                          color: CampusStyle.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = (constraints.maxWidth / 250)
                              .floor()
                              .clamp(1, 3);
                          final cardWidth =
                              (constraints.maxWidth - (columns - 1) * 14) /
                              columns;
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.co_present_rounded,
                                title: 'Mark Student Attendance',
                                description:
                                    'Morning & closing checkpoint marks for classes',
                                buttonLabel: 'Mark Daily',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ClassDailyAttendanceScreen(),
                                  ),
                                ),
                              ),
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.fact_check_rounded,
                                title: 'Review and Edit Student Attendance',
                                description:
                                    'Review full daily roster & audit corrections',
                                buttonLabel: 'Review Daily',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminDailyAttendanceScreen(),
                                  ),
                                ),
                              ),
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.how_to_reg_rounded,
                                title: widget.isPrincipalReadOnly
                                    ? 'Staff & Teacher Roster'
                                    : 'Mark Staff & Teacher Attendance',
                                description:
                                    'Daily check-in/out times, bulk marking, short leave & absent/leave exceptions',
                                buttonLabel: widget.isPrincipalReadOnly
                                    ? 'View Roster'
                                    : 'Mark Now',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MarkStaffAttendanceScreen(
                                      isPrincipalReadOnly:
                                          widget.isPrincipalReadOnly,
                                    ),
                                  ),
                                ),
                              ),
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.fact_check_outlined,
                                title: 'Staff & Teacher Records',
                                description:
                                    'Browse saved check-in/out records, edit with audit reason, history & summary',
                                buttonLabel: 'View Now',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => StaffAttendanceListScreen(
                                      isPrincipalReadOnly:
                                          widget.isPrincipalReadOnly,
                                    ),
                                  ),
                                ),
                              ),
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.groups_outlined,
                                title: 'Student Attendance Records',
                                description:
                                    'View and correct student daily attendance records',
                                buttonLabel: 'Open',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const StudentAttendanceScreen(),
                                  ),
                                ),
                              ),
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.summarize_outlined,
                                title: 'Attendance Summary',
                                description:
                                    'Per-student daily attendance % over a date range',
                                buttonLabel: 'View Summary',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AttendanceSummaryScreen(),
                                  ),
                                ),
                              ),
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.warning_amber_rounded,
                                title: 'Defaulters',
                                description:
                                    'Students below an attendance % threshold',
                                buttonLabel: 'View List',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DefaultersScreen(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'Teacher Check-In/Out & Biometric Kiosk',
                        style: TextStyle(
                          color: CampusStyle.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = (constraints.maxWidth / 250)
                              .floor()
                              .clamp(1, 3);
                          final cardWidth =
                              (constraints.maxWidth - (columns - 1) * 14) /
                              columns;
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.access_time_filled_rounded,
                                title: 'Staff & Teacher Check-In / Out',
                                description:
                                    'Unified daily roster for check-in/out times, short leaves, bulk mark & audit edits',
                                buttonLabel: widget.isPrincipalReadOnly
                                    ? 'View Roster'
                                    : 'Open Check-In/Out',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MarkStaffAttendanceScreen(
                                      isPrincipalReadOnly:
                                          widget.isPrincipalReadOnly,
                                    ),
                                  ),
                                ),
                              ),
                              if (!widget.isPrincipalReadOnly)
                                AttendanceActionCard(
                                  width: cardWidth,
                                  icon: Icons.fingerprint_rounded,
                                  title: 'Attendance Kiosk',
                                  description:
                                      'Arrival & departure fingerprint kiosk scanning mode',
                                  buttonLabel: 'Launch Kiosk',
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherKioskScreen(),
                                    ),
                                  ),
                                ),
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.devices_rounded,
                                title: 'Kiosk Devices',
                                description:
                                    'Register workstations, store tokens & manage scanner attachment',
                                buttonLabel: 'Manage Devices',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AttendanceDevicesScreen(),
                                  ),
                                ),
                              ),
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.badge_rounded,
                                title: 'Fingerprint Enrollment',
                                description:
                                    'Enroll & revoke teacher fingerprint templates per kiosk',
                                buttonLabel: 'Enroll Teachers',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TeacherEnrollmentScreen(),
                                  ),
                                ),
                              ),
                              AttendanceActionCard(
                                width: cardWidth,
                                icon: Icons.tune_rounded,
                                title: 'Attendance Policy',
                                description:
                                    'Configure Mon–Sun start/end times, cutoffs & grace rules',
                                buttonLabel: 'Edit Policy',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AttendancePolicyScreen(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Container(
                        decoration: CampusStyle.card,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Attendance insights',
                              style: TextStyle(
                                color: CampusStyle.ink,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                ChoiceChip(
                                  label: const Text('Class Trends'),
                                  avatar: const Icon(
                                    Icons.pie_chart_outline_rounded,
                                    size: 18,
                                  ),
                                  selected: _view == _TrendsView.classTrends,
                                  onSelected: (_) => setState(
                                    () => _view = _TrendsView.classTrends,
                                  ),
                                ),
                                ChoiceChip(
                                  label: const Text('Teacher Trends'),
                                  avatar: const Icon(
                                    Icons.insights_rounded,
                                    size: 18,
                                  ),
                                  selected: _view == _TrendsView.teacherTrends,
                                  onSelected: (_) => setState(
                                    () => _view = _TrendsView.teacherTrends,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 500,
                              child: _view == _TrendsView.classTrends
                                  ? const ClassTrendsSection()
                                  : const TeacherTrendsSection(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
