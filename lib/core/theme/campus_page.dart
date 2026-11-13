import 'package:flutter/material.dart';
import 'package:cms/core/theme/campus_style.dart';

/// Common presentation for campus forms and reports; each screen owns its state.
class CampusPage extends StatelessWidget {
  const CampusPage({
    super.key,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
  });
  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: const Color(0xFFF5DCD7),
        ),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          fillColor: Colors.white,
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: const WidgetStatePropertyAll(Color(0xFFF7DEDB)),
          dataRowColor: const WidgetStatePropertyAll(Color(0xFFFFFAF8)),
          headingTextStyle: const TextStyle(
            color: CampusStyle.primary,
            fontWeight: FontWeight.w700,
          ),
          dataTextStyle: const TextStyle(color: CampusStyle.ink, fontSize: 14),
          dividerThickness: .5,
        ),
      ),
      child: Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: CampusBackground()),
            SafeArea(child: body),
          ],
        ),
      ),
    );
  }
}

/// Keeps the scrolling hit area full width while limiting reading width.
class CampusScrollView extends StatelessWidget {
  const CampusScrollView({
    super.key,
    this.padding = const EdgeInsets.all(16),
    required this.child,
  });
  final EdgeInsetsGeometry padding;
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: padding,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Container(
          width: double.infinity,
          decoration: CampusStyle.card,
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 480 ? 12 : 24,
          ),
          child: child,
        ),
      ),
    ),
  );
}

class CampusSectionIntro extends StatelessWidget {
  const CampusSectionIntro({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        colors: [Color(0xFF782323), Color(0xFFA63A33)],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFFE2E6FF), height: 1.5),
        ),
      ],
    ),
  );
}
