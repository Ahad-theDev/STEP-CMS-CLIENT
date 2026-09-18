import 'package:flutter/material.dart';
import '../widgets/fee_action_card.dart';
import 'generate_bulk_fees_screen.dart';
import 'generate_student_fee_screen.dart';
import 'view_fee_records_screen.dart';

class FeeRecordsHomeScreen extends StatelessWidget {
  const FeeRecordsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Records')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FeeActionCard(
                icon: Icons.groups_2_outlined,
                title: 'Generate Bulk',
                description: 'Generate a month\'s fee for one or more classes',
                buttonLabel: 'Generate Now',
                backgroundColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF43A047),
                buttonColor: const Color(0xFF388E3C),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const GenerateBulkFeesScreen())),
              ),
              FeeActionCard(
                icon: Icons.person_outline_rounded,
                title: 'Generate for Student',
                description: 'Generate a fee record for one student',
                buttonLabel: 'Generate Now',
                backgroundColor: const Color(0xFFE3F4F6),
                iconColor: const Color(0xFF0795A5),
                buttonColor: const Color(0xFF0795A5),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const GenerateStudentFeeScreen())),
              ),
              FeeActionCard(
                icon: Icons.list_alt_rounded,
                title: 'View Fee Records',
                description: 'Browse a student\'s fee records',
                buttonLabel: 'View Now',
                backgroundColor: const Color(0xFFF6FBFF),
                iconColor: const Color(0xFF1769D1),
                buttonColor: const Color(0xFF1265D4),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ViewFeeRecordsScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}