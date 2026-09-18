import 'package:flutter/material.dart';
import '../widgets/fee_action_card.dart';
import 'fee_structure_home_screen.dart';
import 'fee_records_home_screen.dart';

class FeeHomeScreen extends StatelessWidget {
  const FeeHomeScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fees')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FeeActionCard(
                icon: Icons.payments_outlined,
                title: 'Pay Fee',
                description: 'Record a payment for a student\'s fee',
                buttonLabel: 'Open',
                onPressed: () => _comingSoon(context, 'Pay Fee'),
              ),
              FeeActionCard(
                icon: Icons.calendar_month_outlined,
                title: 'Academic Year Fee',
                description: 'Set, view, and update each class\'s fee structure',
                buttonLabel: 'Open',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const FeeStructureHomeScreen())),
              ),
              FeeActionCard(
                icon: Icons.receipt_long_outlined,
                title: 'Records',
                description: 'Generate and view monthly fee records',
                buttonLabel: 'Open',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const FeeRecordsHomeScreen())),
              ),
              FeeActionCard(
                icon: Icons.event_busy_outlined,
                title: 'Fee Due Students',
                description: 'Due today, overdue, and upcoming payments',
                buttonLabel: 'Open',
                onPressed: () => _comingSoon(context, 'Fee Due Students'),
              ),
              FeeActionCard(
                icon: Icons.warning_amber_rounded,
                title: 'Fee Defaulters',
                description: 'Students with unpaid or partial fees',
                buttonLabel: 'Open',
                onPressed: () => _comingSoon(context, 'Fee Defaulters'),
              ),
              FeeActionCard(
                icon: Icons.summarize_outlined,
                title: 'Fee Summary',
                description: 'Collection totals and efficiency by class',
                buttonLabel: 'Open',
                onPressed: () => _comingSoon(context, 'Fee Summary'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}