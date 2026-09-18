import 'package:flutter/material.dart';
import '../widgets/fee_action_card.dart';
import 'add_fee_structure_screen.dart';
import 'view_fee_structures_screen.dart';

class FeeStructureHomeScreen extends StatelessWidget {
  const FeeStructureHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Year Fee')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FeeActionCard(
                icon: Icons.add_chart_rounded,
                title: 'Create Fee Structure',
                description: 'Set a class\'s fee for an academic year',
                buttonLabel: 'Create Now',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const AddFeeStructureScreen())),
              ),
              FeeActionCard(
                icon: Icons.list_alt_rounded,
                title: 'View Fee Structure',
                description: 'Browse by class and year — tap a row to update',
                buttonLabel: 'View Now',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ViewFeeStructuresScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}