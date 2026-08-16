/// Academy Theme Color Palette
///
/// A professional, academic color system designed for educational institutions.
/// Colors are organized by semantic purpose for consistent usage across the app.
///
/// Usage: Import and use [AppColors] throughout the app. Never use raw color values.
// ignore_for_file: dangling_library_doc_comments

import 'package:flutter/material.dart';

/// Core brand colors - Academy deep navy as primary
class AppColors {
  AppColors._();

  // =========================================================================
  // BRAND COLORS
  // =========================================================================

  /// Primary brand color - Deep academic navy
  /// Used for: primary buttons, key actions, headers, focus states
  static const Color primary = Color(0xFF1B2A4A);

  /// Primary container - Lighter version for backgrounds, chips, cards
  static const Color primaryContainer = Color(0xFFE8EDF5);

  /// On-primary - Text/icons on primary backgrounds
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// On-primary-container - Text on primary container backgrounds
  static const Color onPrimaryContainer = Color(0xFF1B2A4A);

  // =========================================================================
  // SECONDARY COLORS
  // =========================================================================

  /// Secondary brand color - Warm gold accent
  /// Used for: highlights, accents, secondary actions, achievements
  static const Color secondary = Color(0xFFC8A84C);

  /// Secondary container - Subtle gold background
  static const Color secondaryContainer = Color(0xFFFFF8E7);

  /// On-secondary - Text/icons on secondary backgrounds
  static const Color onSecondary = Color(0xFF1B2A4A);

  /// On-secondary-container - Text on secondary container backgrounds
  static const Color onSecondaryContainer = Color(0xFF4A3D14);

  // =========================================================================
  // TERTIARY / ACCENT COLORS
  // =========================================================================

  /// Tertiary - Sage green for success states, growth, progress
  static const Color tertiary = Color(0xFF2E7D32);

  /// Tertiary container - Light sage backgrounds
  static const Color tertiaryContainer = Color(0xFFE8F5E9);

  /// On-tertiary - Text on tertiary backgrounds
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// On-tertiary-container - Text on tertiary container backgrounds
  static const Color onTertiaryContainer = Color(0xFF1B5E20);

  // =========================================================================
  // SEMANTIC STATUS COLORS
  // =========================================================================

  /// Error - For destructive actions, validation errors
  static const Color error = Color(0xFFC62828);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFFB71C1C);

  /// Warning - For cautions, pending states
  static const Color warning = Color(0xFFF57F17);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFFE65100);

  /// Info - For informational messages, links
  static const Color info = Color(0xFF1565C0);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF0D47A1);

  // =========================================================================
  // NEUTRAL / SURFACE COLORS
  // =========================================================================

  /// Surface - Main background for cards, sheets, dialogs
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant - Subtle contrast for alternate rows, inputs
  static const Color surfaceVariant = Color(0xFFF5F6FA);

  /// Surface container - Elevated surfaces (cards on cards)
  static const Color surfaceContainer = Color(0xFFEFF1F5);

  /// Surface container high - Highest elevation surfaces
  static const Color surfaceContainerHigh = Color(0xFFE0E3E9);

  /// On-surface - Primary text on surfaces
  static const Color onSurface = Color(0xFF1B2A4A);

  /// On-surface variant - Secondary text, hints, labels
  static const Color onSurfaceVariant = Color(0xFF5A6A85);

  /// On-surface disabled - Disabled text/icons
  static const Color onSurfaceDisabled = Color(0xFF9AA4B2);

  // =========================================================================
  // BACKGROUND COLORS
  // =========================================================================

  /// App background - Main scaffold background
  static const Color background = Color(0xFFFAFBFD);

  /// On-background - Text on app background
  static const Color onBackground = Color(0xFF1B2A4A);

  // =========================================================================
  // OUTLINE / BORDER COLORS
  // =========================================================================

  /// Outline - Default border color for inputs, cards, dividers
  static const Color outline = Color(0xFFD0D5DD);

  /// Outline variant - Subtle borders, focus rings
  static const Color outlineVariant = Color(0xFFE4E7EC);

  /// Outline strong - Emphasized borders
  static const Color outlineStrong = Color(0xFF9AA4B2);

  // =========================================================================
  // SHADOW / ELEVATION
  // =========================================================================

  /// Shadow color for elevation
  static const Color shadow = Color(0x1A1B2A4A);

  /// Scrim for modals, bottom sheets
  static const Color scrim = Color(0x991B2A4A);

  // =========================================================================
  // ROLE-BASED ACCENT COLORS (for user roles)
  // =========================================================================

  /// Teacher role - Calm blue
  static const Color roleTeacher = Color(0xFF1E88E5);
  static const Color roleTeacherContainer = Color(0xFFE3F2FD);
  static const Color onRoleTeacher = Color(0xFFFFFFFF);

  /// Management role - Professional purple
  static const Color roleManagement = Color(0xFF7B1FA2);
  static const Color roleManagementContainer = Color(0xFFF3E5F5);
  static const Color onRoleManagement = Color(0xFFFFFFFF);

  /// Principal role - Distinguished gold
  static const Color rolePrincipal = Color(0xFFC8A84C);
  static const Color rolePrincipalContainer = Color(0xFFFFF8E7);
  static const Color onRolePrincipal = Color(0xFF4A3D14);

  // =========================================================================
  // HELPER METHODS
  // =========================================================================

  /// Get role color based on role string
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return roleTeacher;
      case 'management':
        return roleManagement;
      case 'principal':
        return rolePrincipal;
      default:
        return primary;
    }
  }

  /// Get role container color
  static Color getRoleContainerColor(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return roleTeacherContainer;
      case 'management':
        return roleManagementContainer;
      case 'principal':
        return rolePrincipalContainer;
      default:
        return primaryContainer;
    }
  }

  /// Get on-role color (text on role background)
  static Color getOnRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return onRoleTeacher;
      case 'management':
        return onRoleManagement;
      case 'principal':
        return onRolePrincipal;
      default:
        return onPrimary;
    }
  }
}

/// Extension for easy access to colors from BuildContext
extension AppColorsExtension on BuildContext {
  Color get primaryColor => AppColors.primary;
  Color get surfaceColor => AppColors.surface;
  Color get backgroundColor => AppColors.background;
  Color get onSurfaceColor => AppColors.onSurface;
  Color get onSurfaceVariantColor => AppColors.onSurfaceVariant;
  Color get outlineColor => AppColors.outline;
  Color get errorColor => AppColors.error;
  Color get successColor => AppColors.tertiary;
  Color get warningColor => AppColors.warning;
}