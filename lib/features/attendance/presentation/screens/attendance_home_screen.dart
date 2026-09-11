import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/features/attendance/presentation/screens/student_attendance_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/attendance_action_card.dart';
import 'mark_staff_attendance_screen.dart';
import 'staff_attendance_list_screen.dart';
import 'analytics_home_screen.dart';

class AttendanceHomeScreen extends StatelessWidget {
  const AttendanceHomeScreen({super.key});

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
                title: 'Mark Attendance',
                description: 'Mark a staff member or teacher present/absent',
                buttonLabel: 'Mark Now',
                backgroundColor: const Color(0xFFF6FBFF),
                iconColor: const Color(0xFF1769D1),
                buttonColor: const Color(0xFF1265D4),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MarkStaffAttendanceScreen(),
                    ),
                  );
                },
              ),
              AttendanceActionCard(
                icon: Icons.fact_check_outlined,
                title: 'View Attendance',
                description: 'Browse staff/teacher attendance by date',
                buttonLabel: 'View Now',
                backgroundColor: const Color(0xFFEAE8F4),
                iconColor: const Color(0xFF7941C4),
                buttonColor: const Color(0xFF7335C5),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StaffAttendanceListScreen(),
                    ),
                  );
                },
              ),
              AttendanceActionCard(
                icon: Icons.groups_outlined,
                title: 'Student Attendance',
                description: 'View, summarize, and correct student records',
                buttonLabel: 'Open',
                backgroundColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF43A047),
                buttonColor: const Color(0xFF388E3C),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StudentAttendanceScreen(),
                    ),
                  );
                },
              ),
              AttendanceActionCard(
                icon: Icons.analytics_outlined,
                title: 'Analytics',
                description:
                    'Trends and defaulters across classes and teachers',
                buttonLabel: 'Open',
                backgroundColor: AppColors.secondaryContainer,
                iconColor: AppColors.secondary,
                buttonColor: AppColors.secondary,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AnalyticsHomeScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
