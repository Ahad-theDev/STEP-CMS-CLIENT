import 'package:flutter/material.dart';
import '../widgets/attendance_action_card.dart';
import 'view_student_attendance_screen.dart';
import 'correct_attendance_screen.dart';

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  // Colors inspired by student management screen
  static const Color _viewAttendanceBg = Color(0xFFF6FBFF);
  static const Color _viewAttendanceIcon = Color(0xFF1769D1);
  static const Color _viewAttendanceBtn = Color(0xFF1265D4);

  static const Color _correctAttendanceBg = Color(0xFFFFF8E1);
  static const Color _correctAttendanceIcon = Color(0xFFF5B041);
  static const Color _correctAttendanceBtn = Color(0xFFEF6B73);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Attendance')),
      body: Padding(
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
              backgroundColor: _viewAttendanceBg,
              iconColor: _viewAttendanceIcon,
              buttonColor: _viewAttendanceBtn,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ViewStudentAttendanceScreen())),
            ),
            AttendanceActionCard(
              icon: Icons.edit_note_rounded,
              title: 'Correct Attendance',
              description: 'Fix or add a student\'s record for a lecture',
              buttonLabel: 'Correct Now',
              backgroundColor: _correctAttendanceBg,
              iconColor: _correctAttendanceIcon,
              buttonColor: _correctAttendanceBtn,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const CorrectAttendanceScreen())),
            ),
          ],
        ),
      ),
    );
  }
}