/// App Dialog Usage Examples
///
/// This file demonstrates various ways to use the AppDialog component.
/// Import this in your screens to see usage patterns.
// ignore_for_file: dangling_library_doc_comments, avoid_print

import 'package:flutter/material.dart';
import 'app_dialog.dart';

/// Example: Simple error dialog
Future<void> showErrorExample(BuildContext context) async {
  await AppDialog.showError(
    context: context,
    title: 'Error',
    message: 'Something went wrong. Please try again.',
    actionLabel: 'OK',
    onActionPressed: () {
      // Handle OK action
      print('Error acknowledged');
    },
  );
}

/// Example: Simple info dialog
Future<void> showInfoExample(BuildContext context) async {
  await AppDialog.show(
    context: context,
    title: 'Information',
    message: 'Your changes have been saved successfully.',
    actionLabel: 'Got it',
    icon: AppDialogIcons.infoIcon(context),
  );
}

/// Example: Confirmation dialog (e.g., delete confirmation)
Future<void> showDeleteConfirmationExample(BuildContext context) async {
  final confirmed = await AppDialog.showConfirmation(
    context: context,
    title: 'Delete User',
    message: 'Are you sure you want to delete this user? This action cannot be undone.',
    confirmLabel: 'Delete',
    cancelLabel: 'Cancel',
    isDestructive: true,
    onConfirm: () {
      // Handle delete action
      print('User deleted');
    },
    onCancel: () {
      // Handle cancel action
      print('Deletion cancelled');
    },
  );

  if (confirmed == true) {
    print('User confirmed deletion');
  }
}

/// Example: Custom dialog with form content
Future<void> showCustomFormDialogExample(BuildContext context) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  await AppDialog.showCustom(
    context: context,
    title: 'Edit Profile',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
          ),
        ),
      ],
    ),
    actions: [
      DialogAction.secondary(
        label: 'Cancel',
        onPressed: () => Navigator.of(context).pop(),
      ),
      DialogAction.primary(
        label: 'Save',
        onPressed: () {
          // Handle save with form data
          final name = nameController.text;
          final email = emailController.text;
          print('Saving: $name, $email');
          Navigator.of(context).pop({'name': name, 'email': email});
        },
      ),
    ],
  );
}

/// Example: Custom dialog with multiple actions (stacked vertically)
Future<void> showMultiActionDialogExample(BuildContext context) async {
  await AppDialog.showCustom(
    context: context,
    title: 'Export Options',
    content: const Text('Choose how you want to export your data:'),
    actions: [
      DialogAction.secondary(
        label: 'Export as PDF',
        onPressed: () {
          Navigator.of(context).pop('pdf');
        },
      ),
      DialogAction.secondary(
        label: 'Export as CSV',
        onPressed: () {
          Navigator.of(context).pop('csv');
        },
      ),
      DialogAction.secondary(
        label: 'Export as JSON',
        onPressed: () {
          Navigator.of(context).pop('json');
        },
      ),
      DialogAction.primary(
        label: 'Cancel',
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

/// Example: Success dialog
Future<void> showSuccessExample(BuildContext context) async {
  await AppDialog.show(
    context: context,
    title: 'Success!',
    message: 'Your account has been created successfully.',
    actionLabel: 'Continue',
    icon: AppDialogIcons.successIcon(),
    onActionPressed: () {
      Navigator.of(context).pushNamed('/dashboard');
    },
  );
}

/// Example: Warning dialog
Future<void> showWarningExample(BuildContext context) async {
  await AppDialog.show(
    context: context,
    title: 'Warning',
    message: 'You have unsaved changes. Leaving this page will discard them.',
    actionLabel: 'Stay',
    icon: AppDialogIcons.warningIcon(),
    onActionPressed: () {
      // User chose to stay
    },
  );
}

/// Example widget showing all dialog types
class DialogExamplesScreen extends StatelessWidget {
  const DialogExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleButton(
            context,
            'Error Dialog',
            Icons.error_outline,
            showErrorExample,
          ),
          _buildExampleButton(
            context,
            'Info Dialog',
            Icons.info_outline,
            showInfoExample,
          ),
          _buildExampleButton(
            context,
            'Success Dialog',
            Icons.check_circle_outline,
            showSuccessExample,
          ),
          _buildExampleButton(
            context,
            'Warning Dialog',
            Icons.warning_amber_outlined,
            showWarningExample,
          ),
          _buildExampleButton(
            context,
            'Delete Confirmation',
            Icons.delete_outline,
            showDeleteConfirmationExample,
          ),
          _buildExampleButton(
            context,
            'Custom Form Dialog',
            Icons.edit_outlined,
            showCustomFormDialogExample,
          ),
          _buildExampleButton(
            context,
            'Multi-Action Dialog',
            Icons.more_horiz,
            showMultiActionDialogExample,
          ),
        ],
      ),
    );
  }

  Widget _buildExampleButton(
    BuildContext context,
    String title,
    IconData icon,
    Future<void> Function(BuildContext) onPressed,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onPressed(context),
      ),
    );
  }
}