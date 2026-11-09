import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/features/ai/presentation/screens/ai_assistant_screen.dart';
import 'package:cms/features/attendance/presentation/screens/class_daily_attendance_screen.dart';
import 'package:cms/features/exams/presentation/screens/teacher_my_exams_screen.dart';
import 'package:cms/features/lectures/presentation/teacher/my_schedule_screen.dart';
import 'package:flutter/material.dart';

class TeacherDashboardBody extends StatelessWidget {
  const TeacherDashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CampusScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CampusSectionIntro(
            title: 'Ready for your teaching day?',
            subtitle:
                'Check your timetable, manage class daily attendance, and find answers about your classes.',
          ),
          const SizedBox(height: 26),
          Text(
            'Your teaching workspace',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 600 ? 2 : 1;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  // 1. Class In-Charge Attendance (Primary Daily Action)
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.co_present_rounded,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Class In-Charge Attendance',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Mark morning arrival and closing dismissal attendance for your assigned class.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ClassDailyAttendanceScreen(),
                                  ),
                                ),
                                child: const Text('Mark Daily Attendance'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. My Timetable & Schedule (Pure Lecture Schedule)
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'My Timetable & Schedule',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'View your daily and weekly lecture schedule, classroom allocations, and timings.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MyScheduleScreen(),
                                  ),
                                ),
                                child: const Text('View Timetable'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Daily Attendance History
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Daily Attendance History',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Browse past daily attendance records, morning statuses, and closing marks.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ClassDailyAttendanceScreen(),
                                  ),
                                ),
                                child: const Text('View History'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. Class Examinations & Results
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.assignment_turned_in_rounded,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Examinations & Marks',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create term exams, enter subject marks, and publish verified class results.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TeacherMyExamsScreen(),
                                  ),
                                ),
                                child: const Text('Manage Exams'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 5. AI Assistant
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'AI Assistant',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ask about your classes, schedule, curriculum, and school guidelines.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AiAssistantScreen(),
                                  ),
                                ),
                                child: const Text('Chat with AI'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
