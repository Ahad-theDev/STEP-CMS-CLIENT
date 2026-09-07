import 'package:flutter/material.dart';
import '../widgets/attendance_action_card.dart';
import 'mark_staff_attendance_screen.dart';
import 'staff_attendance_list_screen.dart';

class AttendanceHomeScreen extends StatelessWidget {
  const AttendanceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Padding(
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
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const MarkStaffAttendanceScreen()));
              },
            ),
            AttendanceActionCard(
              icon: Icons.fact_check_outlined,
              title: 'View Attendance',
              description: 'Browse staff/teacher attendance by date',
              buttonLabel: 'View Now',
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const StaffAttendanceListScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}