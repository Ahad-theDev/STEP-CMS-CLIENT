import 'package:flutter/material.dart';
import 'package:cms/core/theme/app_colors.dart';
import 'subject_action_card.dart';

class SubjectActionCardsRow extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onSearch;

  const SubjectActionCardsRow({
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
          SubjectActionCard(
            icon: Icons.menu_book_rounded,
            title: 'Create Subject',
            description: 'Add a new subject',
            buttonLabel: 'Create Now',
            onPressed: onCreate,
            backgroundColor: AppColors.primaryContainer,
            iconColor: AppColors.primary,
            buttonColor: AppColors.primary,
            titleColor: AppColors.onPrimaryContainer,
            descriptionColor: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          SubjectActionCard(
            icon: Icons.edit_rounded,
            title: 'Update Subject',
            description: 'Edit subject name or code',
            buttonLabel: 'Update Now',
            onPressed: onUpdate,
            backgroundColor: AppColors.secondaryContainer,
            iconColor: AppColors.secondary,
            buttonColor: AppColors.secondary,
            titleColor: AppColors.onSecondaryContainer,
            descriptionColor: AppColors.onSecondaryContainer.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          SubjectActionCard(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Subject',
            description: 'Remove a subject from the system',
            buttonLabel: 'Delete Now',
            onPressed: onDelete,
            backgroundColor: AppColors.errorContainer,
            iconColor: AppColors.error,
            buttonColor: AppColors.error,
            titleColor: AppColors.onErrorContainer,
            descriptionColor: AppColors.onErrorContainer.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          SubjectActionCard(
            icon: Icons.search_rounded,
            title: 'Search Subjects',
            description: 'View and search all subjects',
            buttonLabel: 'Search Now',
            onPressed: onSearch,
            backgroundColor: AppColors.tertiaryContainer,
            iconColor: AppColors.tertiary,
            buttonColor: AppColors.tertiary,
            titleColor: AppColors.onTertiaryContainer,
            descriptionColor: AppColors.onTertiaryContainer.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }
}