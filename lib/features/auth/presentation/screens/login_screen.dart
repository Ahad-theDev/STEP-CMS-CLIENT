import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/auth/application/auth_repository_provider.dart';
import 'package:cms/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:cms/features/auth/presentation/screens/request_password_reset_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Sign In Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF16A34A),
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Success',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      await _showSuccessDialog('Welcome back!');
      if (!mounted) return;
      try {
        final user = await ref.read(authRepositoryProvider).getCurrentUser();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardScreen(user: user)),
        );
      } catch (e) {
        await _showErrorDialog('Failed to get user data. Please log in again.');
      }
    }
  }

  void _handleForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RequestPasswordResetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorDialog(next.error.toString());
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FD),
      body: Stack(
        children: [
          const Positioned.fill(child: CampusBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Institutional Branding (Dark contrast logo & typography)
                      const _HeaderSection(),
                      const SizedBox(height: 24),
                      // Elevated Clean Card with Noticeable Purplish Tint
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFF6F1FF),
                              Color(0xFFF0F6FF),
                            ],
                            stops: [0.0, 0.55, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFDADDF4),
                            width: 1,
                          ), // Refined purple border
                          boxShadow: const [
                            BoxShadow(
                              color: Color(
                                0x127C3AED,
                              ), // Noticeable ambient purple shadow
                              blurRadius: 30,
                              offset: Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Color(0x080F172A),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Welcome back. Sign in to your campus portal.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _UsernameField(controller: _usernameController),
                              const SizedBox(height: 16),
                              _PasswordField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                onToggleVisibility: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _RememberMeAndForgotPassword(
                                rememberMe: _rememberMe,
                                onRememberMeChanged: (value) => setState(
                                  () => _rememberMe = value ?? false,
                                ),
                                onForgotPassword: _handleForgotPassword,
                              ),
                              const SizedBox(height: 22),
                              _SubmitButton(
                                isLoading: isLoading,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: 18),
                              const _FooterSection(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Subtle campus footer indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'STEP CMS • Campus & Mobile Edition',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Original-style squircle with bluish & purple gradient
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF153D79), // Original Academy deep navy blue
                Color(0xFF2867A9), // Deep rich collegiate purple
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFF60A5FA).withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x350E2147),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x283B82F6),
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'lib/core/assets/logo/CMS-LOGO-F.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.school_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'STEP ACADEMY',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Daroghawala Campus',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username],
      decoration: InputDecoration(
        labelText: 'Username',
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF6D28D9),
          fontWeight: FontWeight.w600,
        ),
        hintText: 'Enter your username',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(
          Icons.person_outline_rounded,
          color: Color(0xFF6250B8),
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9DFF0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9DFF0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6250B8), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Username is required';
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
  });
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enableSuggestions: false,
      autocorrect: false,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF6D28D9),
          fontWeight: FontWeight.w600,
        ),
        hintText: 'Enter your password',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: Color(0xFF6250B8),
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF6250B8),
            size: 20,
          ),
          onPressed: onToggleVisibility,
          tooltip: obscureText ? 'Show password' : 'Hide password',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9DFF0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9DFF0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6250B8), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Password is required';
        }
        return null;
      },
    );
  }
}

class _RememberMeAndForgotPassword extends StatelessWidget {
  const _RememberMeAndForgotPassword({
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
  });
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: rememberMe,
                onChanged: onRememberMeChanged,
                activeColor: const Color(0xFF6250B8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFC4B5FD), width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onRememberMeChanged(!rememberMe),
              child: const Text(
                'Remember me',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onForgotPassword,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6250B8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              color: Color(0xFF6250B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4345A6), // Campus indigo
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(
            0xFF4345A6,
          ).withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shadowColor: const Color(0x404345A6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 17),
                ],
              ),
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: Divider(color: Color(0xFFDDE2F2), thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFDDE2F2), thickness: 1)),
          ],
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help & Support - coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(
            Icons.help_outline_rounded,
            size: 16,
            color: Color(0xFF6250B8),
          ),
          label: const Text(
            'Need help? Contact support',
            style: TextStyle(
              color: Color(0xFF6250B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
