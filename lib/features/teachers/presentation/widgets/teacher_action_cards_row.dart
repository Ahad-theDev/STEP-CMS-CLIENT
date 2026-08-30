import 'package:flutter/material.dart';
import 'teacher_action_card.dart';

class TeacherActionCardsRow extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onSearch;
  final VoidCallback onBulkImport;
  final VoidCallback onCreate;

  const TeacherActionCardsRow({
    super.key,
    required this.onUpdate,
    required this.onDelete,
    required this.onSearch,
    required this.onBulkImport,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          TeacherActionCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Create Teacher',
            description: 'Register a new teacher account',
            buttonLabel: 'Create Now',
            onPressed: onCreate,
            backgroundColor: const Color(0xFFE3F4F6),
            iconColor: const Color(0xFF0795A5),
            buttonColor: const Color(0xFF0795A5),
          ),
          const SizedBox(width: 12),
          TeacherActionCard(
            icon: Icons.edit_rounded,
            title: 'Update Teacher',
            description: 'Edit teacher department, qualification, etc.',
            buttonLabel: 'Update Now',
            onPressed: onUpdate,
            backgroundColor: const Color(0xFFF6FBFF),
            iconColor: const Color(0xFF1769D1),
            buttonColor: const Color(0xFF1265D4),
          ),
          const SizedBox(width: 12),
          TeacherActionCard(
            icon: Icons.person_remove_rounded,
            title: 'Delete Teacher',
            description: 'Deactivate a teacher account',
            buttonLabel: 'Delete Now',
            onPressed: onDelete,
            backgroundColor: const Color(0xFFF3E9E8),
            iconColor: const Color(0xFFE84245),
            buttonColor: const Color(0xFFED4043),
          ),
          const SizedBox(width: 12),
          TeacherActionCard(
            icon: Icons.search_rounded,
            title: 'Search Teachers',
            description: 'View and search all teachers',
            buttonLabel: 'Search Now',
            onPressed: onSearch,
            backgroundColor: const Color(0xFFEAE8F4),
            iconColor: const Color(0xFF7941C4),
            buttonColor: const Color(0xFF7335C5),
          ),
          const SizedBox(width: 12),
          TeacherActionCard(
            icon: Icons.upload_file_rounded,
            title: 'Bulk Import',
            description: 'Import teachers from a CSV file',
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