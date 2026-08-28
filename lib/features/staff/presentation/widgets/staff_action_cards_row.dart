import 'package:flutter/material.dart';
import 'staff_action_card.dart';

class StaffActionCardsRow extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onSearch;

  const StaffActionCardsRow({
    super.key,
    required this.onCreate,
    required this.onUpdate,
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
          StaffActionCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Create Staff',
            description: 'Add a new staff member',
            buttonLabel: 'Create Now',
            onPressed: onCreate,
            backgroundColor: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF1565C0),
            buttonColor: const Color(0xFF1565C0),
          ),
          const SizedBox(width: 12),
          StaffActionCard(
            icon: Icons.edit_rounded,
            title: 'Update Staff',
            description: 'Edit staff information',
            buttonLabel: 'Update Now',
            onPressed: onUpdate,
            backgroundColor: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF6A1B9A),
            buttonColor: const Color(0xFF6A1B9A),
          ),
          const SizedBox(width: 12),
          StaffActionCard(
            icon: Icons.person_remove_rounded,
            title: 'Delete Staff',
            description: 'Remove staff from the system',
            buttonLabel: 'Delete Now',
            onPressed: onDelete,
            backgroundColor: const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFC62828),
            buttonColor: const Color(0xFFC62828),
          ),
          const SizedBox(width: 12),
          StaffActionCard(
            icon: Icons.search_rounded,
            title: 'Search Staff',
            description: 'Search and view all staff',
            buttonLabel: 'Search Now',
            onPressed: onSearch,
            backgroundColor: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF6A1B9A),
            buttonColor: const Color(0xFF6A1B9A),
          ),
        ],
      ),
    );
  }
}