import 'package:cms/core/theme/campus_style.dart';
import 'package:flutter/material.dart';

class AttendanceStatusBadge extends StatelessWidget {
  final String status;

  const AttendanceStatusBadge({super.key, required this.status});

  static Color colorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return const Color(0xFF16A34A);
      case 'late':
        return const Color(0xFFD97706);
      case 'absent':
        return const Color(0xFFDC2626);
      case 'leave':
        return const Color(0xFF2563EB);
      default:
        return CampusStyle.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForStatus(status);
    final label = status.isEmpty
        ? 'UNKNOWN'
        : '${status[0].toUpperCase()}${status.substring(1)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ShortLeaveBadge extends StatelessWidget {
  const ShortLeaveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: const Text(
        'Short Leave',
        style: TextStyle(
          color: Color(0xFFB45309),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AttendanceSourceChip extends StatelessWidget {
  final String? source;

  const AttendanceSourceChip({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    if (source == null || source!.isEmpty) return const SizedBox.shrink();
    final isFingerprint = source!.toLowerCase() == 'fingerprint';
    final color =
        isFingerprint ? CampusStyle.primary : const Color(0xFF475569);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFingerprint
                ? Icons.fingerprint_rounded
                : Icons.edit_calendar_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              isFingerprint ? 'Fingerprint' : 'Manual',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
