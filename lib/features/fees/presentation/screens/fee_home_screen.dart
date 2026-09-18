import 'package:flutter/material.dart';
import '../widgets/fee_action_card.dart';
import 'fee_structure_home_screen.dart';
import 'fee_records_home_screen.dart';
import 'pay_fee_screen.dart';
import 'fee_due_students_screen.dart';
import 'fee_defaulters_screen.dart';
import 'fee_summary_screen.dart';

class FeeHomeScreen extends StatelessWidget {
  const FeeHomeScreen({super.key});

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
                backgroundColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF43A047),
                buttonColor: const Color(0xFF388E3C),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const PayFeeScreen())),
              ),
              FeeActionCard(
                icon: Icons.calendar_month_outlined,
                title: 'Academic Year Fee',
                description:
                    'Set, view, and update each class\'s fee structure',
                buttonLabel: 'Open',
                backgroundColor: const Color(0xFFF6FBFF),
                iconColor: const Color(0xFF1769D1),
                buttonColor: const Color(0xFF1265D4),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FeeStructureHomeScreen(),
                  ),
                ),
              ),
              FeeActionCard(
                icon: Icons.receipt_long_outlined,
                title: 'Records',
                description: 'Generate and view monthly fee records',
                buttonLabel: 'Open',
                backgroundColor: const Color(0xFFEAE8F4),
                iconColor: const Color(0xFF7941C4),
                buttonColor: const Color(0xFF7335C5),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FeeRecordsHomeScreen(),
                  ),
                ),
              ),
              FeeActionCard(
                icon: Icons.event_busy_outlined,
                title: 'Fee Due Students',
                description: 'Due today, overdue, and upcoming payments',
                buttonLabel: 'Open',
                backgroundColor: const Color(0xFFFFF8E1),
                iconColor: const Color(0xFFF9A825),
                buttonColor: const Color(0xFFF57F17),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FeeDueStudentsScreen(),
                  ),
                ),
              ),
              FeeActionCard(
                icon: Icons.warning_amber_rounded,
                title: 'Fee Defaulters',
                description: 'Students with unpaid or partial fees',
                buttonLabel: 'Open',
                backgroundColor: const Color(0xFFF3E9E8),
                iconColor: const Color(0xFFE84245),
                buttonColor: const Color(0xFFED4043),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FeeDefaultersScreen(),
                  ),
                ),
              ),
              FeeActionCard(
                icon: Icons.summarize_outlined,
                title: 'Fee Summary',
                description: 'Collection totals and efficiency by class',
                buttonLabel: 'Open',
                backgroundColor: const Color(0xFFE3F4F6),
                iconColor: const Color(0xFF0795A5),
                buttonColor: const Color(0xFF0795A5),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FeeSummaryScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
