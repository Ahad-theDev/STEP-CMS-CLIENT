import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/reset_password_controller.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  static const _specialChars = r'!@#$%^&*()_+-=[]|;:,.<>?';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUpper => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLower => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasDigit => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _passwordController.text.split('').any((c) => _specialChars.contains(c));
  bool get _isValidPassword =>
      _hasMinLength && _hasUpper && _hasLower && _hasDigit && _hasSpecial;

  Future<void> _submit() async {
    if (_tokenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Paste your reset token')));
      return;
    }
    if (!_isValidPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password doesn\'t meet all requirements')));
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final message = await ref.read(resetPasswordControllerProvider.notifier).submit(
          token: _tokenController.text.trim(),
          newPassword: _passwordController.text,
        );
    if (!mounted || message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _requirement(String label, bool met) {
    return Row(
      children: [
        Icon(met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16, color: met ? Colors.green : Colors.grey),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: met ? Colors.green : Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Reset Token',
                helperText: 'From the server console — email delivery isn\'t set up yet',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _requirement('8+ characters', _hasMinLength),
                _requirement('Uppercase letter', _hasUpper),
                _requirement('Lowercase letter', _hasLower),
                _requirement('Digit', _hasDigit),
                _requirement('Special character', _hasSpecial),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
            ),
            const SizedBox(height: 24),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Failed: ${friendlyErrorMessage(state.error!)}',
                    style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}