import 'package:cms/core/theme/campus_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/request_password_reset_controller.dart';
import 'reset_password_screen.dart';

class RequestPasswordResetScreen extends ConsumerStatefulWidget {
  const RequestPasswordResetScreen({super.key});

  @override
  ConsumerState<RequestPasswordResetScreen> createState() =>
      _RequestPasswordResetScreenState();
}

class _RequestPasswordResetScreenState
    extends ConsumerState<RequestPasswordResetScreen> {
  final _identifierController = TextEditingController();
  String? _resultMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_identifierController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your username or email')),
      );
      return;
    }

    final message = await ref
        .read(requestPasswordResetControllerProvider.notifier)
        .submit(_identifierController.text.trim());
    if (!mounted) return;

    if (message == null) {
      final error = ref.read(requestPasswordResetControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error != null
                ? friendlyErrorMessage(error)
                : 'Something went wrong',
          ),
        ),
      );
      return;
    }

    setState(() => _resultMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestPasswordResetControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CampusBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back to sign in'),
                          style: TextButton.styleFrom(
                            foregroundColor: CampusStyle.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: CampusStyle.card,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF153D79),
                                      Color(0xFF2867A9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.lock_reset_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: CampusStyle.ink,
                                letterSpacing: -.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enter your username or email to request password reset instructions.',
                              style: TextStyle(
                                fontSize: 14,
                                color: CampusStyle.muted,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 26),
                            TextField(
                              controller: _identifierController,
                              style: const TextStyle(
                                color: CampusStyle.ink,
                                fontSize: 15,
                              ),
                              decoration: CampusStyle.input(
                                'Username or email',
                                Icons.person_outline_rounded,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CampusStyle.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0x994345A6,
                                  ),
                                  disabledForegroundColor: Colors.white70,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Send reset instructions',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            if (_resultMessage != null) ...[
                              const SizedBox(height: 20),
                              Semantics(
                                liveRegion: true,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDF7F3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _resultMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFF21634E),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: CampusStyle.accent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFD9DFF0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ResetPasswordScreen(),
                                  ),
                                ),
                                child: const Text('I have my reset token'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'STEP ACADEMY • Daroghawala Campus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CampusStyle.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
