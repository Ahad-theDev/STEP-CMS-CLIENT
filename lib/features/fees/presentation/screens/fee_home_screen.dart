import 'package:cms/core/theme/campus_style.dart';
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
      appBar: AppBar(
        title: const Text('Fees'),
        backgroundColor: const Color(0xFFE4DDF3),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: CampusBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width < 480 ? 16 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1192),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF253E7A), Color(0xFF554490)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xFFDBE7FF),
                              size: 30,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Campus fees, in one place.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Record payments, manage fee structures, and review outstanding balances.',
                              style: TextStyle(
                                color: Color(0xFFE2E6FF),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'Fee management',
                        style: TextStyle(
                          color: CampusStyle.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose a task to get started.',
                        style: TextStyle(
                          color: CampusStyle.muted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = (constraints.maxWidth / 260)
                              .floor()
                              .clamp(1, 3);
                          final cardWidth =
                              (constraints.maxWidth - (columns - 1) * 14) /
                              columns;
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              FeeActionCard(
                                width: cardWidth,
                                icon: Icons.payments_outlined,
                                title: 'Pay Fee',
                                description:
                                    'Record a payment for a student\'s fee',
                                buttonLabel: 'Open',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PayFeeScreen(),
                                  ),
                                ),
                              ),
                              FeeActionCard(
                                width: cardWidth,
                                icon: Icons.calendar_month_outlined,
                                title: 'Academic Year Fee',
                                description:
                                    'Set, view, and update each class\'s fee structure',
                                buttonLabel: 'Open',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FeeStructureHomeScreen(),
                                  ),
                                ),
                              ),
                              FeeActionCard(
                                width: cardWidth,
                                icon: Icons.receipt_long_outlined,
                                title: 'Records',
                                description:
                                    'Generate and view monthly fee records',
                                buttonLabel: 'Open',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FeeRecordsHomeScreen(),
                                  ),
                                ),
                              ),
                              FeeActionCard(
                                width: cardWidth,
                                icon: Icons.event_busy_outlined,
                                title: 'Fee Due Students',
                                description:
                                    'Due today, overdue, and upcoming payments',
                                buttonLabel: 'Open',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FeeDueStudentsScreen(),
                                  ),
                                ),
                              ),
                              FeeActionCard(
                                width: cardWidth,
                                icon: Icons.warning_amber_rounded,
                                title: 'Fee Defaulters',
                                description:
                                    'Students with unpaid or partial fees',
                                buttonLabel: 'Open',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const FeeDefaultersScreen(),
                                  ),
                                ),
                              ),
                              FeeActionCard(
                                width: cardWidth,
                                icon: Icons.summarize_outlined,
                                title: 'Fee Summary',
                                description:
                                    'Collection totals and efficiency by class',
                                buttonLabel: 'Open',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const FeeSummaryScreen(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
