/// Academy Theme Color Palette
///
/// A professional, academic color system designed for educational institutions.
/// Colors are organized by semantic purpose for consistent usage across the app.
///
/// Usage: Import and use [AppColors] throughout the app. Never use raw color values.
// ignore_for_file: dangling_library_doc_comments

import 'package:flutter/material.dart';

/// Core brand colors - Deep navy with purple accent
class AppColors {
  AppColors._();

  // =========================================================================
  // BRAND COLORS
  // =========================================================================

  /// Primary brand color - Soft purple accent
  /// Used for: primary buttons, key actions, headers, focus states
  static const Color primary = Color(0xFF4345A6);

  /// Primary container - Lighter version for backgrounds, chips, cards
  static const Color primaryContainer = Color(0xFFE1DDF5);

  /// On-primary - Text/icons on primary backgrounds
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// On-primary-container - Text on primary container backgrounds
  static const Color onPrimaryContainer = Color(0xFF2A225D);

  // =========================================================================
  // SECONDARY COLORS
  // =========================================================================

  /// Secondary brand color - Light violet accent
  /// Used for: highlights, accents, secondary actions
  static const Color secondary = Color(0xFF6250B8);

  /// Secondary container - Subtle violet background
  static const Color secondaryContainer = Color(0xFFE8E0F8);

  /// On-secondary - Text/icons on secondary backgrounds
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// On-secondary-container - Text on secondary container backgrounds
  static const Color onSecondaryContainer = Color(0xFF4A3D7A);

  // =========================================================================
  // TERTIARY / ACCENT COLORS
  // =========================================================================

  /// Tertiary - Soft blue for subtle accents
  static const Color tertiary = Color(0xFF326DA0);

  /// Tertiary container - Light blue backgrounds
  static const Color tertiaryContainer = Color(0xFFD8E6FA);

  /// On-tertiary - Text on tertiary backgrounds
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// On-tertiary-container - Text on tertiary container backgrounds
  static const Color onTertiaryContainer = Color(0xFF1A345D);

  // =========================================================================
  // SEMANTIC STATUS COLORS
  // =========================================================================

  /// Error - For destructive actions, validation errors
  static const Color error = Color(0xFFB43C50);
  static const Color errorContainer = Color(0xFFF9CED2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF9B0025);

  /// Warning - For cautions, pending states
  static const Color warning = Color(0xFFF5B041);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFFBF360C);

  /// Info - For informational messages, links
  static const Color info = Color(0xFF326DA0);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF0D47A1);

  // =========================================================================
  // NEUTRAL / SURFACE COLORS
  // =========================================================================

  /// Surface - Main background for cards, sheets, dialogs
  static const Color surface = Color(0xFFFCFAFF);

  /// Surface variant - Subtle contrast for alternate rows, inputs
  static const Color surfaceVariant = Color(0xFFEEF0FC);

  /// Surface container - Elevated surfaces (cards on cards)
  static const Color surfaceContainer = Color(0xFFF4F1FC);

  /// Surface container high - Highest elevation surfaces
  static const Color surfaceContainerHigh = Color(0xFFEBE7F6);

  /// Surface container highest - Even higher elevation
  static const Color surfaceContainerHighest = Color(0xFFE1DDF0);

  /// Surface container low - Lower elevation surfaces
  static const Color surfaceContainerLow = Color(0xFFF8F6FD);

  /// Surface container lowest - Lowest elevation
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  /// On-surface - Primary text on surfaces
  static const Color onSurface = Color(0xFF0F172A);

  /// On-surface variant - Secondary text, hints, labels
  static const Color onSurfaceVariant = Color(0xFF526079);

  /// On-surface disabled - Disabled text/icons
  static const Color onSurfaceDisabled = Color(0xFF737F95);

  // =========================================================================
  // BACKGROUND COLORS
  // =========================================================================

  /// App background - Main scaffold background
  static const Color background = Color(0xFFEEF0FC);

  /// On-background - Text on app background
  static const Color onBackground = Color(0xFF0F172A);

  // =========================================================================
  // OUTLINE / BORDER COLORS
  // =========================================================================

  /// Outline - Default border color for inputs, cards, dividers
  static const Color outline = Color(0xFF858BA5);

  /// Outline variant - Subtle borders, focus rings
  static const Color outlineVariant = Color(0xFFD9DFF0);

  /// Outline strong - Emphasized borders
  static const Color outlineStrong = Color(0xFF6250B8);

  // =========================================================================
  // SHADOW / ELEVATION
  // =========================================================================

  /// Shadow color for elevation
  static const Color shadow = Color(0x1A000000);

  /// Scrim for modals, bottom sheets
  static const Color scrim = Color(0x99000000);

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
