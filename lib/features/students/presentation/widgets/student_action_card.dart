import 'package:flutter/material.dart';

class StudentActionCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? buttonColor;

  const StudentActionCard({
    super.key,
    this.width = 220,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).colorScheme.primary)
                      .withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onPressed,
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
