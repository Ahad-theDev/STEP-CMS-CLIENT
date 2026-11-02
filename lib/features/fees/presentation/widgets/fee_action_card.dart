import 'package:flutter/material.dart';

class FeeActionCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? buttonColor;
  final Color? textColor;
  final Color? descriptionColor;

  const FeeActionCard({
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
    this.textColor,
    this.descriptionColor,
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
                  color: Theme.of(context).colorScheme.primaryContainer,
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
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      descriptionColor ??
                      Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        buttonColor ?? Theme.of(context).colorScheme.primary,
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
