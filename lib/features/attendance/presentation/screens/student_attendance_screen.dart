import 'package:flutter/material.dart';
import '../widgets/attendance_action_card.dart';
import 'view_student_attendance_screen.dart';
import 'correct_attendance_screen.dart';
import 'attendance_summary_screen.dart';

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Attendance')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AttendanceActionCard(
                icon: Icons.list_alt_rounded,
                title: 'View Attendance',
                description: 'Browse a class\'s attendance by date',
                buttonLabel: 'View Now',
                backgroundColor: const Color(0xFFF6FBFF),
                iconColor: const Color(0xFF1769D1),
                buttonColor: const Color(0xFF1265D4),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ViewStudentAttendanceScreen())),
              ),
              AttendanceActionCard(
                icon: Icons.edit_note_rounded,
                title: 'Correct Attendance',
                description: 'Fix or add a student\'s record for a lecture',
                buttonLabel: 'Correct Now',
                backgroundColor: const Color(0xFFFFFFFA),
                iconColor: const Color(0xFFF0A020),
                buttonColor: const Color(0xFFF5A018),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const CorrectAttendanceScreen())),
              ),
              AttendanceActionCard(
                icon: Icons.pie_chart_outline_rounded,
                title: 'Summary',
                description: 'Per-student attendance % over a date range',
                buttonLabel: 'View Summary',
                backgroundColor: const Color(0xFFEAE8F4),
                iconColor: const Color(0xFF7941C4),
                buttonColor: const Color(0xFF7335C5),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const AttendanceSummaryScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}