import 'package:flutter/material.dart';
import 'student_action_card.dart';

class StudentActionCardsRow extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onUpdate;
  final VoidCallback onChangeEnrollment;
  final VoidCallback onDelete;
  final VoidCallback onSearch;
  final VoidCallback onBulkImport;

  const StudentActionCardsRow({
    super.key,
    required this.onCreate,
    required this.onUpdate,
    required this.onChangeEnrollment,
    required this.onDelete,
    required this.onSearch,
    required this.onBulkImport,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 260).floor().clamp(1, 3);
        final cardWidth = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StudentActionCard(
                width: cardWidth,
                icon: Icons.person_add_alt_1_rounded,
                title: 'Create Student',
                description: 'Add a new student to the system',
                buttonLabel: 'Create Now',
                onPressed: onCreate,
              ),
              StudentActionCard(
                width: cardWidth,
                icon: Icons.edit_rounded,
                title: 'Update Student',
                description: 'Edit student information',
                buttonLabel: 'Update Now',
                onPressed: onUpdate,
              ),
              StudentActionCard(
                width: cardWidth,
                icon: Icons.swap_horiz_rounded,
                title: 'Change Enrollment',
                description: 'Change student class / section',
                buttonLabel: 'Change Now',
                onPressed: onChangeEnrollment,
              ),
              StudentActionCard(
                width: cardWidth,
                icon: Icons.delete_outline_rounded,
                title: 'Delete Student',
                description: 'Deactivate a student record',
                buttonLabel: 'Delete Now',
                onPressed: onDelete,
                iconColor: const Color(0xFFB43C50),
                buttonColor: const Color(0xFFB43C50),
              ),
              StudentActionCard(
                width: cardWidth,
                icon: Icons.search_rounded,
                title: 'Search Student',
                description: 'Search and view students by class',
                buttonLabel: 'Search Now',
                onPressed: onSearch,
              ),
              StudentActionCard(
                width: cardWidth,
                icon: Icons.upload_file_rounded,
                title: 'Bulk Import',
                description: 'Import students from a CSV file',
                buttonLabel: 'Import Now',
                onPressed: onBulkImport,
              ),
            ],
          ),
        );
      },
    );
  }
}
