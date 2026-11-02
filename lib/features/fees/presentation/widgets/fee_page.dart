import 'package:flutter/material.dart';
import 'package:cms/core/theme/campus_style.dart';

/// Common presentation for fee forms and reports; each screen owns its state.
class FeePage extends StatelessWidget {
  const FeePage({super.key, required this.appBar, required this.body});
  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: const Color(0xFFE4DDF3),
        ),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          fillColor: Colors.white,
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: const WidgetStatePropertyAll(Color(0xFFE1DDF5)),
          dataRowColor: const WidgetStatePropertyAll(Color(0xFFFCFAFF)),
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
class FeeScrollView extends StatelessWidget {
  const FeeScrollView({
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

class FeeSectionIntro extends StatelessWidget {
  const FeeSectionIntro({
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
        colors: [Color(0xFF253E7A), Color(0xFF554490)],
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
