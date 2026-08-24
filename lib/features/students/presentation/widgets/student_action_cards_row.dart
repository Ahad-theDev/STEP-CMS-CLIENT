import 'package:flutter/material.dart';
import 'student_action_card.dart';

class StudentActionCardsRow extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onUpdate;
  final VoidCallback onChangeEnrollment;
  final VoidCallback onDelete;
  final VoidCallback onSearch;

  const StudentActionCardsRow({
    super.key,
    required this.onCreate,
    required this.onUpdate,
    required this.onChangeEnrollment,
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
          StudentActionCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Create Student',
            description: 'Add a new student to the system',
            buttonLabel: 'Create Now',
            onPressed: onCreate,
          ),
          const SizedBox(width: 12),
          StudentActionCard(
            icon: Icons.edit_rounded,
            title: 'Update Student',
            description: 'Edit student information',
            buttonLabel: 'Update Now',
            onPressed: onUpdate,
          ),
          const SizedBox(width: 12),
          StudentActionCard(
            icon: Icons.swap_horiz_rounded,
            title: 'Change Enrollment',
            description: 'Change student class / section',
            buttonLabel: 'Change Now',
            onPressed: onChangeEnrollment,
          ),
          const SizedBox(width: 12),
          StudentActionCard(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Student',
            description: 'Remove student from system',
            buttonLabel: 'Delete Now',
            onPressed: onDelete,
          ),
          const SizedBox(width: 12),
          StudentActionCard(
            icon: Icons.search_rounded,
            title: 'Search Student',
            description: 'Search and view students by class',
            buttonLabel: 'Search Now',
            onPressed: onSearch,
          ),
        ],
      ),
    );
  }
}