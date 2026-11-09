import 'package:flutter/material.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'daily_attendance_report_screen.dart';
import 'lecture_attendance_report_screen.dart';
import 'fee_report_screen.dart';
import 'marks_report_screen.dart';

class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CampusPage(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: CampusScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CampusSectionIntro(
              title: 'Institutional Analytics & Reporting',
              subtitle:
                  'Generate verified academic, attendance, and financial reports with exportable PDF documents.',
            ),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 600;
                final cardWidth = isDesktop
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // 1. Daily Attendance Report
                    _buildReportCard(
                      context,
                      width: cardWidth,
                      title: 'Daily Attendance Report',
                      description:
                          'Track student morning arrival and dismissal attendance, absenteeism rates, and working day summaries.',
                      icon: Icons.co_present_rounded,
                      color: const Color(0xFF1E88E5),
                      targetScreen: const DailyAttendanceReportScreen(),
                    ),

                    // 2. Lecture Attendance Report
                    _buildReportCard(
                      context,
                      width: cardWidth,
                      title: 'Lecture Attendance Report',
                      description:
                          'Detailed period-by-period lecture delivery and subject engagement rates for all classes.',
                      icon: Icons.calendar_today_rounded,
                      color: const Color(0xFF8E24AA),
                      targetScreen: const LectureAttendanceReportScreen(),
                    ),

                    // 3. Fee Collection Report
                    _buildReportCard(
                      context,
                      width: cardWidth,
                      title: 'Fee Collection & Defaulters',
                      description:
                          'Invoicing totals, payments collected, outstanding dues, recovery rates, and defaulter tracking.',
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF2E7D32),
                      targetScreen: const FeeReportScreen(),
                    ),

                    // 4. Exam Marks & Merit Report
                    _buildReportCard(
                      context,
                      width: cardWidth,
                      title: 'Exam Marks & Merit Report',
                      description:
                          'Official academic rankings, class average percentages, subject statistics, and printable merit lists.',
                      icon: Icons.assignment_turned_in_rounded,
                      color: CampusStyle.primary,
                      targetScreen: const MarksReportScreen(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required double width,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Widget targetScreen,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: CampusStyle.ink,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => targetScreen),
                    );
                  },
                  child: const Text('Open Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
