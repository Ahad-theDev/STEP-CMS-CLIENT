import 'package:flutter/material.dart';
import 'package:cms/core/theme/app_colors.dart';
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
            iconColor: AppColors.roleTeacher, // Blue for create/add action
            buttonColor: AppColors.roleTeacher,
          ),
          const SizedBox(width: 12),
          StaffActionCard(
            icon: Icons.edit_rounded,
            title: 'Update Staff',
            description: 'Edit staff information',
            buttonLabel: 'Update Now',
            onPressed: onUpdate,
            iconColor: AppColors.tertiary, // Light blue for update action
            buttonColor: AppColors.tertiary,
          ),
          const SizedBox(width: 12),
          StaffActionCard(
            icon: Icons.person_remove_rounded,
            title: 'Delete Staff',
            description: 'Remove staff from the system',
            buttonLabel: 'Delete Now',
            onPressed: onDelete,
            iconColor: AppColors.error, // Red for delete action
            buttonColor: AppColors.error,
          ),
          const SizedBox(width: 12),
          StaffActionCard(
            icon: Icons.search_rounded,
            title: 'Search Staff',
            description: 'Search and view all staff',
            buttonLabel: 'Search Now',
            onPressed: onSearch,
            iconColor: AppColors.primary, // Purple for search action
            buttonColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}