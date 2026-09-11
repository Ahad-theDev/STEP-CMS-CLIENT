import 'package:flutter/material.dart';
import 'package:cms/core/theme/app_colors.dart';
import '../widgets/attendance_action_card.dart';
import 'class_trends_screen.dart';
import 'teacher_trends_screen.dart';
import 'defaulters_screen.dart';

class AnalyticsHomeScreen extends StatelessWidget {
  const AnalyticsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            AttendanceActionCard(
              icon: Icons.bar_chart_rounded,
              title: 'Class Trends',
              description: 'Daily attendance % for a class over a range',
              buttonLabel: 'View Trends',
              backgroundColor: AppColors.tertiaryContainer,
              iconColor: AppColors.tertiary,
              buttonColor: AppColors.tertiary,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ClassTrendsScreen())),
            ),
            AttendanceActionCard(
              icon: Icons.insights_rounded,
              title: 'Teacher Trends',
              description: 'Daily attendance % per class a teacher teaches',
              buttonLabel: 'View Trends',
              backgroundColor: AppColors.primaryContainer,
              iconColor: AppColors.primary,
              buttonColor: AppColors.primary,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const TeacherTrendsScreen())),
            ),
            AttendanceActionCard(
              icon: Icons.warning_amber_rounded,
              title: 'Defaulters',
              description: 'Students below an attendance % threshold',
              buttonLabel: 'View List',
              backgroundColor: AppColors.warningContainer,
              iconColor: AppColors.warning,
              buttonColor: AppColors.warning,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const DefaultersScreen())),
            ),
          ],
        ),
      ),
    );
  }
}