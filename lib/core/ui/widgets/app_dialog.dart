/// Generic App Dialog Component
///
/// A reusable dialog component that supports:
/// - Error dialogs with a single action
/// - Confirmation dialogs with two actions (confirm/cancel)
/// - Custom content dialogs
/// - Proper theming with rounded corners matching the app design system
// ignore_for_file: dangling_library_doc_comments

import 'package:flutter/material.dart';

/// Configuration for dialog actions
class DialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;

  const DialogAction({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  /// Primary action (e.g., Confirm, Save, OK)
  factory DialogAction.primary({
    required String label,
    VoidCallback? onPressed,
  }) {
    return DialogAction(
      label: label,
      onPressed: onPressed,
      isPrimary: true,
    );
  }

  /// Secondary action (e.g., Cancel, Close)
  factory DialogAction.secondary({
    required String label,
    VoidCallback? onPressed,
  }) {
    return DialogAction(
      label: label,
      onPressed: onPressed,
      isPrimary: false,
    );
  }

  /// Destructive action (e.g., Delete, Remove)
  factory DialogAction.destructive({
    required String label,
    VoidCallback? onPressed,
  }) {
    return DialogAction(
      label: label,
      onPressed: onPressed,
      isPrimary: true,
      isDestructive: true,
    );
  }
}

/// Dialog type for predefined configurations
enum AppDialogType {
  /// Simple error/info dialog with single action
  simple,
  /// Confirmation dialog with two actions
  confirmation,
  /// Custom dialog with flexible actions
  custom,
}

/// A generic, theme-aware dialog component
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.title,
    this.content,
    this.icon,
    this.actions = const [],
    this.type = AppDialogType.custom,
    this.barrierDismissible = true,
    this.contentPadding = const EdgeInsets.all(24),
    this.actionsPadding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
    this.maxWidth = 400,
    this.borderRadius = 24,
  });

  /// Dialog title
  final String? title;

  /// Dialog content (text or custom widget)
  final Widget? content;

  /// Optional icon to display at the top
  final Widget? icon;

  /// List of actions (buttons) at the bottom
  final List<DialogAction> actions;

  /// Predefined dialog type for quick setup
  final AppDialogType type;

  /// Whether dialog can be dismissed by tapping barrier
  final bool barrierDismissible;

  /// Padding around content
  final EdgeInsetsGeometry contentPadding;

  /// Padding around actions
  final EdgeInsetsGeometry actionsPadding;

  /// Maximum width of dialog
  final double maxWidth;

  /// Border radius for rounded corners
  final double borderRadius;

  /// Show a simple error/info dialog with single action
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Widget? icon,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppDialog(
        title: title,
        content: Text(message),
        icon: icon,
        actions: [
          DialogAction.primary(
            label: actionLabel ?? 'OK',
            onPressed: () {
              onActionPressed?.call();
              Navigator.of(context).pop();
            },
          ),
        ],
        type: AppDialogType.simple,
      ),
    );
  }

  /// Show an error dialog with error styling
  static Future<T?> showError<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return show<T>(
      context: context,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      icon: const _ErrorIcon(),
    );
  }

  /// Show a confirmation dialog with two actions
  static Future<bool?> showConfirmation<T>({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    Widget? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: Text(message),
        icon: icon,
        actions: [
          DialogAction.secondary(
            label: cancelLabel,
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
          ),
          isDestructive
              ? DialogAction.destructive(
                  label: confirmLabel,
                  onPressed: () {
                    onConfirm?.call();
                    Navigator.of(context).pop(true);
                  },
                )
              : DialogAction.primary(
                  label: confirmLabel,
                  onPressed: () {
                    onConfirm?.call();
                    Navigator.of(context).pop(true);
                  },
                ),
        ],
        type: AppDialogType.confirmation,
      ),
    );
  }

  /// Show a custom dialog with flexible configuration
  static Future<T?> showCustom<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    Widget? icon,
    required List<DialogAction> actions,
    bool barrierDismissible = true,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(24),
    EdgeInsetsGeometry actionsPadding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
    double maxWidth = 400,
    double borderRadius = 24,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        icon: icon,
        actions: actions,
        type: AppDialogType.custom,
        barrierDismissible: barrierDismissible,
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        maxWidth: maxWidth,
        borderRadius: borderRadius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determine default actions based on type if not provided
    final effectiveActions = _getEffectiveActions(context);

    return Dialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with icon and title
              if (icon != null || title != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    contentPadding.resolve(Directionality.of(context)).left,
                    contentPadding.resolve(Directionality.of(context)).top,
                    contentPadding.resolve(Directionality.of(context)).right,
                    0,
                  ),
                  child: Column(
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(height: 16),
                      ],
                      if (title != null)
                        Text(
                          title!,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),

              // Content
              if (content != null)
                Padding(
                  padding: contentPadding,
                  child: DefaultTextStyle.merge(
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                    child: content!,
                  ),
                ),

              // Actions
              if (effectiveActions.isNotEmpty)
                Padding(
                  padding: actionsPadding,
                  child: _buildActions(context, effectiveActions),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<DialogAction> _getEffectiveActions(BuildContext context) {
    if (actions.isNotEmpty) return actions;

    // Default actions based on type
    switch (type) {
      case AppDialogType.simple:
        return [
          DialogAction.primary(
            label: 'OK',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ];
      case AppDialogType.confirmation:
        return [
          DialogAction.secondary(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          DialogAction.primary(
            label: 'Confirm',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ];
      case AppDialogType.custom:
        return const [];
    }
  }

  Widget _buildActions(BuildContext context, List<DialogAction> actions) {
    final isSingleAction = actions.length == 1;
    final isTwoActions = actions.length == 2;

    if (isSingleAction) {
      return _buildActionButton(context, actions.first, isPrimary: true);
    }

    if (isTwoActions) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(context, actions[0], isPrimary: false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(context, actions[1], isPrimary: true),
          ),
        ],
      );
    }

    // Multiple actions - stack vertically
    return Column(
      children: actions
          .map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildActionButton(context, action, isPrimary: action.isPrimary),
              ))
          .toList(),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    DialogAction action, {
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color backgroundColor;
    Color foregroundColor;
    Color? overlayColor;
    BorderSide? side;

    if (action.isDestructive) {
      backgroundColor = colorScheme.error;
      foregroundColor = colorScheme.onError;
      overlayColor = colorScheme.onError.withValues(alpha: 0.12);
    } else if (isPrimary && action.isPrimary) {
      backgroundColor = colorScheme.primary;
      foregroundColor = colorScheme.onPrimary;
      overlayColor = colorScheme.onPrimary.withValues(alpha: 0.12);
    } else {
      backgroundColor = colorScheme.surfaceContainer;
      foregroundColor = colorScheme.onSurface;
      overlayColor = colorScheme.onSurface.withValues(alpha: 0.12);
      side = BorderSide(color: colorScheme.outline, width: 1.5);
    }

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          overlayColor: overlayColor,
          side: side,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        child: Text(action.label),
      ),
    );
  }
}

/// Error icon widget for error dialogs
class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.error_outline_rounded,
        size: 28,
        color: colorScheme.error,
      ),
    );
  }
}

/// Success icon widget for success dialogs
class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.check_circle_outline_rounded,
        size: 28,
        color: colorScheme.tertiary,
      ),
    );
  }
}

/// Warning icon widget for warning dialogs
class _WarningIcon extends StatelessWidget {
  const _WarningIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.warning_amber_rounded,
        size: 28,
        color: colorScheme.secondary,
      ),
    );
  }
}

/// Helper class for dialog icons
class AppDialogIcons {
  /// Create an error dialog icon
  static Widget errorIcon() => const _ErrorIcon();

  /// Create a success dialog icon
  static Widget successIcon() => const _SuccessIcon();

  /// Create a warning dialog icon
  static Widget warningIcon() => const _WarningIcon();

  /// Create an info dialog icon
  static Widget infoIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.info_outline_rounded,
        size: 28,
        color: colorScheme.primary,
      ),
    );
  }
}