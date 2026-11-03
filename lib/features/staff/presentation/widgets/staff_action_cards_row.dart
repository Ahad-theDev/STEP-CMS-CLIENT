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
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 260).floor().clamp(1, 4);
        final cardWidth = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              StaffActionCard(
                width: cardWidth,
                icon: Icons.person_add_alt_1_rounded,
                title: 'Create Staff',
                description: 'Add a new staff member',
                buttonLabel: 'Create Now',
                onPressed: onCreate,
              ),
              StaffActionCard(
                width: cardWidth,
                icon: Icons.edit_rounded,
                title: 'Update Staff',
                description: 'Edit staff information',
                buttonLabel: 'Update Now',
                onPressed: onUpdate,
              ),
              StaffActionCard(
                width: cardWidth,
                icon: Icons.person_remove_rounded,
                title: 'Delete Staff',
                description: 'Deactivate a staff record',
                buttonLabel: 'Delete Now',
                onPressed: onDelete,
                iconColor: const Color(0xFFB43C50),
                buttonColor: const Color(0xFFB43C50),
              ),
              StaffActionCard(
                width: cardWidth,
                icon: Icons.search_rounded,
                title: 'Search Staff',
                description: 'Search and view all staff',
                buttonLabel: 'Search Now',
                onPressed: onSearch,
              ),
            ],
          ),
        );
      },
    );
  }
}
