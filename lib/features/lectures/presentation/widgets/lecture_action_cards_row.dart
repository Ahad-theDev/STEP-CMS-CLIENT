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

  const LectureActionCardsRow({
    super.key,
    required this.onCreate,
    required this.onUpdate,
    required this.onCreateOverride,
    required this.onBulkShift,
    required this.onPreviewSchedule,
    required this.onDelete,
    required this.onSearch,
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
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.edit_rounded,
            title: 'Update Lecture',
            description: 'Edit a permanent weekly slot',
            buttonLabel: 'Update Now',
            onPressed: onUpdate,
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.event_repeat_rounded,
            title: 'Create Override',
            description: 'One-off change for a specific date',
            buttonLabel: 'Override Now',
            onPressed: onCreateOverride,
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.schedule_rounded,
            title: 'Bulk Shift',
            description: "Shift a whole day's lectures by N minutes",
            buttonLabel: 'Shift Now',
            onPressed: onBulkShift,
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Lecture',
            description: 'Remove a permanent slot',
            buttonLabel: 'Delete Now',
            onPressed: onDelete,
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.preview_rounded,
            title: 'Preview Schedule',
            description: "See a specific date's resolved schedule",
            buttonLabel: 'Preview Now',
            onPressed: onPreviewSchedule,
          ),
          const SizedBox(width: 12),
          LectureActionCard(
            icon: Icons.search_rounded,
            title: 'Search Lectures',
            description: 'View and filter all lectures',
            buttonLabel: 'Search Now',
            onPressed: onSearch,
          ),
        ],
      ),
    );
  }
}