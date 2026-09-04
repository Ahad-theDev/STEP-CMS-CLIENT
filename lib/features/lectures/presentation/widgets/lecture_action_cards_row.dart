import 'package:flutter/material.dart';
import 'lecture_action_card.dart';

class LectureActionCardsRow extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onUpdate;
  final VoidCallback onCreateOverride;
  final VoidCallback onBulkShift;
  final VoidCallback onPreviewSchedule;
  final VoidCallback onDelete;
  final VoidCallback onSearch;
  final VoidCallback onCalendar;

  const LectureActionCardsRow({
    super.key,
    required this.onCreate,
    required this.onUpdate,
    required this.onCreateOverride,
    required this.onBulkShift,
    required this.onPreviewSchedule,
    required this.onDelete,
    required this.onSearch,
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          LectureActionCard(
            icon: Icons.add_alarm_rounded,
            title: 'Create Lecture',
            description: 'Add a permanent weekly slot',
            buttonLabel: 'Create Now',
            onPressed: onCreate,
            backgroundColor: const Color(0xFFE3F4F6),
            iconColor: const Color(0xFF0795A5),
            buttonColor: const Color(0xFF0795A5),
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.edit_rounded,
            title: 'Update Lecture',
            description: 'Edit a permanent weekly slot',
            buttonLabel: 'Update Now',
            onPressed: onUpdate,
            backgroundColor: const Color(0xFFF6FBFF),
            iconColor: const Color(0xFF1769D1),
            buttonColor: const Color(0xFF1265D4),
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.event_repeat_rounded,
            title: 'Create Override',
            description: 'One-off change for a specific date',
            buttonLabel: 'Override Now',
            onPressed: onCreateOverride,
            backgroundColor: const Color(0xFFFFFFFA),
            iconColor: const Color(0xFFF0A020),
            buttonColor: const Color(0xFFF5A018),
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.schedule_rounded,
            title: 'Bulk Shift',
            description: "Shift a whole day's lectures by N minutes",
            buttonLabel: 'Shift Now',
            onPressed: onBulkShift,
            backgroundColor: const Color(0xFFF3E9E8),
            iconColor: const Color(0xFFE84245),
            buttonColor: const Color(0xFFED4043),
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.preview_rounded,
            title: 'Preview Schedule',
            description: "See a specific date's resolved schedule",
            buttonLabel: 'Preview Now',
            onPressed: onPreviewSchedule,
            backgroundColor: const Color(0xFFEAE8F4),
            iconColor: const Color(0xFF7941C4),
            buttonColor: const Color(0xFF7335C5),
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Lecture',
            description: 'Remove a permanent slot',
            buttonLabel: 'Delete Now',
            onPressed: onDelete,
            backgroundColor: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF43A047),
            buttonColor: const Color(0xFF388E3C),
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.search_rounded,
            title: 'Search Lectures',
            description: 'View and filter all lectures',
            buttonLabel: 'Search Now',
            onPressed: onSearch,
            backgroundColor: const Color(0xFFE3F4F6),
            iconColor: const Color(0xFF0795A5),
            buttonColor: const Color(0xFF0795A5),
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.calendar_month_rounded,
            title: 'Calendar',
            description: 'Manage holidays and events',
            buttonLabel: 'Open Calendar',
            onPressed: onCalendar,
            backgroundColor: const Color(0xFFF6FBFF),
            iconColor: const Color(0xFF1769D1),
            buttonColor: const Color(0xFF1265D4),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
