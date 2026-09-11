import 'package:cms/features/lectures/presentation/teacher/my_schedule_screen.dart';
import 'package:flutter/material.dart';


class TeacherDashboardBody extends StatelessWidget {
  const TeacherDashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 220,
        child: Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                const Text('My Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('View your timetable and mark attendance',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const MyScheduleScreen())),
                    child: const Text('Open'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}