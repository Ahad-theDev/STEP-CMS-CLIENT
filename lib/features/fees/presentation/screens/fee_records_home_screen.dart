import '../widgets/fee_page.dart';
import 'package:flutter/material.dart';
import '../widgets/fee_action_card.dart';
import 'generate_bulk_fees_screen.dart';
import 'generate_student_fee_screen.dart';
import 'view_fee_records_screen.dart';

class FeeRecordsHomeScreen extends StatelessWidget {
  const FeeRecordsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeePage(
      appBar: AppBar(title: const Text('Fee Records')),
      body: FeeScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FeeSectionIntro(
              title: 'Fee records',
              subtitle:
                  'Generate monthly fees or review existing student records.',
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
                      icon: Icons.groups_2_outlined,
                      title: 'Generate Bulk',
                      description:
                          'Generate a month\'s fee for one or more classes',
                      buttonLabel: 'Generate Now',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GenerateBulkFeesScreen(),
                        ),
                      ),
                    ),
                    FeeActionCard(
                      width: cardWidth,
                      icon: Icons.person_outline_rounded,
                      title: 'Generate for Student',
                      description: 'Generate a fee record for one student',
                      buttonLabel: 'Generate Now',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GenerateStudentFeeScreen(),
                        ),
                      ),
                    ),
                    FeeActionCard(
                      width: cardWidth,
                      icon: Icons.list_alt_rounded,
                      title: 'View Fee Records',
                      description: 'Browse a student\'s fee records',
                      buttonLabel: 'View Now',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ViewFeeRecordsScreen(),
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
