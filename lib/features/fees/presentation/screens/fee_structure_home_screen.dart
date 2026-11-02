import '../widgets/fee_page.dart';
import 'package:flutter/material.dart';
import '../widgets/fee_action_card.dart';
import 'add_fee_structure_screen.dart';
import 'view_fee_structures_screen.dart';

class FeeStructureHomeScreen extends StatelessWidget {
  const FeeStructureHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeePage(
      appBar: AppBar(title: const Text('Academic Year Fee')),
      body: FeeScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FeeSectionIntro(
              title: 'Academic year fees',
              subtitle: 'Create and manage fee structures for your classes.',
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = (constraints.maxWidth / 260).floor().clamp(
                  1,
                  3,
                );
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * 14) / columns;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    FeeActionCard(
                      width: cardWidth,
                      icon: Icons.add_chart_rounded,
                      title: 'Create Fee Structure',
                      description: 'Set a class\'s fee for an academic year',
                      buttonLabel: 'Create Now',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddFeeStructureScreen(),
                        ),
                      ),
                    ),
                    FeeActionCard(
                      width: cardWidth,
                      icon: Icons.list_alt_rounded,
                      title: 'View Fee Structure',
                      description:
                          'Browse by class and year — tap a row to update',
                      buttonLabel: 'View Now',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ViewFeeStructuresScreen(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
