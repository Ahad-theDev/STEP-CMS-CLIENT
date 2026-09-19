import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/request_password_reset_controller.dart';
import 'reset_password_screen.dart';

class RequestPasswordResetScreen extends ConsumerStatefulWidget {
  const RequestPasswordResetScreen({super.key});

  @override
  ConsumerState<RequestPasswordResetScreen> createState() => _RequestPasswordResetScreenState();
}

class _RequestPasswordResetScreenState extends ConsumerState<RequestPasswordResetScreen> {
  final _identifierController = TextEditingController();
  String? _resultMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_identifierController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter your username or email')));
      return;
    }

    final message = await ref
        .read(requestPasswordResetControllerProvider.notifier)
        .submit(_identifierController.text.trim());
    if (!mounted) return;

    if (message == null) {
      final error = ref.read(requestPasswordResetControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error != null ? friendlyErrorMessage(error) : 'Something went wrong'),
      ));
      return;
    }

    setState(() => _resultMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestPasswordResetControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text(
              'Enter your username or email. If an account exists, a reset token will be generated.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _identifierController,
              decoration: const InputDecoration(labelText: 'Username or Email'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Send Reset Token'),
            ),
            if (_resultMessage != null) ...[
              const SizedBox(height: 20),
              Text(_resultMessage!, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                ),
                child: const Text('I have my reset token'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}