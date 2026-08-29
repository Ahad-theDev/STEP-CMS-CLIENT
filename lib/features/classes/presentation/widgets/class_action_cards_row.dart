import 'package:flutter/material.dart';
import 'class_action_card.dart';

class ClassActionCardsRow extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onUpdate;
  final VoidCallback onAssignTeacher;
  final VoidCallback onDelete;
  final VoidCallback onSearch;
  final VoidCallback onBulkImport;

  const ClassActionCardsRow({
    super.key,
    required this.onCreate,
    required this.onUpdate,
    required this.onAssignTeacher,
    required this.onDelete,
    required this.onSearch,
    required this.onBulkImport,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          ClassActionCard(
            icon: Icons.add_business_rounded,
            title: 'Create Class',
            description: 'Add a new class/section',
            buttonLabel: 'Create Now',
            onPressed: onCreate,
            backgroundColor: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF388E3C),
            buttonColor: const Color(0xFF388E3C),
          ),
          const SizedBox(width: 12),
          ClassActionCard(
            icon: Icons.edit_rounded,
            title: 'Update Class',
            description: 'Edit class name, section, year',
            buttonLabel: 'Update Now',
            onPressed: onUpdate,
            backgroundColor: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF6A1B9A),
            buttonColor: const Color(0xFF6A1B9A),
          ),
          const SizedBox(width: 12),
          ClassActionCard(
            icon: Icons.person_pin_circle_rounded,
            title: 'Assign Teacher',
            description: 'Set or change the class teacher',
            buttonLabel: 'Assign Now',
            onPressed: onAssignTeacher,
            backgroundColor: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF6A1B9A),
            buttonColor: const Color(0xFF6A1B9A),
          ),
          const SizedBox(width: 12),
          ClassActionCard(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Class',
            description: 'Remove a class from the system',
            buttonLabel: 'Delete Now',
            onPressed: onDelete,
            backgroundColor: const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFC62828),
            buttonColor: const Color(0xFFC62828),
          ),
          const SizedBox(width: 12),
          ClassActionCard(
            icon: Icons.search_rounded,
            title: 'Search Classes',
            description: 'View and search all classes',
            buttonLabel: 'Search Now',
            onPressed: onSearch,
            backgroundColor: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF6A1B9A),
            buttonColor: const Color(0xFF6A1B9A),
          ),
          const SizedBox(width: 12),
          ClassActionCard(
            icon: Icons.upload_file_rounded,
            title: 'Bulk Import',
            description: 'Import classes from a CSV file',
            buttonLabel: 'Import Now',
            onPressed: onBulkImport,
            backgroundColor: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF388E3C),
            buttonColor: const Color(0xFF388E3C),
          ),
        ],
      ),
    );
  }
}