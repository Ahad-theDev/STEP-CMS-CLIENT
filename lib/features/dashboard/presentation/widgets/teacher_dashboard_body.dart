import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'package:cms/features/ai/presentation/screens/ai_assistant_screen.dart';
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
                'Check your timetable, mark attendance, and find answers about your classes.',
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
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'My Schedule',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'View your timetable and mark attendance',
                              style: TextStyle(
                                fontSize: 12,
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
                                child: const Text('Open'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                            const SizedBox(height: 4),
                            const Text(
                              'Ask about your classes, schedule & student attendance',
                              style: TextStyle(
                                fontSize: 12,
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
