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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          StudentActionCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Create Student',
            description: 'Add a new student to the system',
            buttonLabel: 'Create Now',
            onPressed: onCreate,
            backgroundColor: const Color(0xFFE3F4F6),
            iconColor: const Color(0xFF0795A5),
            buttonColor: const Color(0xFF0795A5),
          ),
          const SizedBox(width: 12),
          StudentActionCard(
            icon: Icons.edit_rounded,
            title: 'Update Student',
            description: 'Edit student information',
            buttonLabel: 'Update Now',
            onPressed: onUpdate,
            backgroundColor: const Color(0xFFF6FBFF),
            iconColor: const Color(0xFF1769D1),
            buttonColor: const Color(0xFF1265D4),
          ),
          const SizedBox(width: 12),
          StudentActionCard(
            icon: Icons.swap_horiz_rounded,
            title: 'Change Enrollment',
            description: 'Change student class / section',
            buttonLabel: 'Change Now',
            onPressed: onChangeEnrollment,
            backgroundColor: const Color(0xFFFFFFFA),
            iconColor: const Color(0xFFF0A020),
            buttonColor: const Color(0xFFF5A018),
          ),
          const SizedBox(width: 12),
          StudentActionCard(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Student',
            description: 'Remove student from system',
            buttonLabel: 'Delete Now',
            onPressed: onDelete,
            backgroundColor: const Color(0xFFF3E9E8),
            iconColor: const Color(0xFFE84245),
            buttonColor: const Color(0xFFED4043),
          ),
          const SizedBox(width: 12),
          StudentActionCard(
            icon: Icons.search_rounded,
            title: 'Search Student',
            description: 'Search and view students by class',
            buttonLabel: 'Search Now',
            onPressed: onSearch,
            backgroundColor: const Color(0xFFEAE8F4),
            iconColor: const Color(0xFF7941C4),
            buttonColor: const Color(0xFF7335C5),
          ),
          const SizedBox(width: 12),
          StudentActionCard(
            icon: Icons.upload_file_rounded,
            title: 'Bulk Import',
            description: 'Import students from a CSV file',
            buttonLabel: 'Import Now',
            onPressed: onBulkImport,
            backgroundColor: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF43A047),
            buttonColor: const Color(0xFF388E3C),
          ),
        ],
      ),
    );
  }
}