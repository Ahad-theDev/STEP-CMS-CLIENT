import 'package:flutter/material.dart';
import '../widgets/attendance_summary_section.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Summary')),
      body: const AttendanceSummarySection(),
    );
  }
}