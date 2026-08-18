import 'package:cms/features/auth/application/auth_controller.dart';
import 'package:cms/features/auth/data/models/register_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'teacher';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_rounded, color: Theme.of(context).colorScheme.error, size: 28),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = RegisterRequest(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      fullName: _fullNameController.text.trim(),
      password: _passwordController.text.trim(),
      role: _role,
    );

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(request);

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.tertiary, size: 28),
              const SizedBox(width: 12),
              const Text('Success'),
            ],
          ),
          content: const Text('User created successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _formKey.currentState!.reset();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    // Show error dialog when auth state has error (also handled in initState listener)
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        _showErrorDialog(next.error.toString());
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Create User'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderSection(colorScheme: colorScheme),
                    const SizedBox(height: 32),
                    // Responsive layout: two fields per row on larger screens
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideScreen = constraints.maxWidth > 500;
                        if (isWideScreen) {
                          return Column(
                            children: [
                              // First row: Username and Email
                              Row(
                                children: [
                                  Expanded(
                                    child: _UsernameField(
                                      controller: _usernameController,
                                      colorScheme: colorScheme,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _EmailField(
                                      controller: _emailController,
                                      colorScheme: colorScheme,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Second row: Phone and FullName
                              Row(
                                children: [
                                  Expanded(
                                    child: _PhoneField(
                                      controller: _phoneController,
                                      colorScheme: colorScheme,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _FullNameField(
                                      controller: _fullNameController,
                                      colorScheme: colorScheme,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Third row: Password and Role
                              Row(
                                children: [
                                  Expanded(
                                    child: _PasswordField(
                                      controller: _passwordController,
                                      colorScheme: colorScheme,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _RoleDropdown(
                                      initialValue: _role,
                                      onChanged: (v) => setState(() => _role = v ?? 'teacher'),
                                      colorScheme: colorScheme,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Submit button full width
                              _SubmitButton(
                                isLoading: isLoading,
                                onPressed: _submit,
                                colorScheme: colorScheme,
                              ),
                            ],
                          );
                        } else {
                          // Original single column layout for narrow screens
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _UsernameField(
                                controller: _usernameController,
                                colorScheme: colorScheme,
                              ),
                              const SizedBox(height: 16),
                              _EmailField(
                                controller: _emailController,
                                colorScheme: colorScheme,
                              ),
                              const SizedBox(height: 16),
                              _PhoneField(
                                controller: _phoneController,
                                colorScheme: colorScheme,
                              ),
                              const SizedBox(height: 16),
                              _FullNameField(
                                controller: _fullNameController,
                                colorScheme: colorScheme,
                              ),
                              const SizedBox(height: 16),
                              _PasswordField(
                                controller: _passwordController,
                                colorScheme: colorScheme,
                              ),
                              const SizedBox(height: 16),
                              _RoleDropdown(
                                initialValue: _role,
                                onChanged: (v) => setState(() => _role = v ?? 'teacher'),
                                colorScheme: colorScheme,
                              ),
                              const SizedBox(height: 24),
                              _SubmitButton(
                                isLoading: isLoading,
                                onPressed: _submit,
                                colorScheme: colorScheme,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.person_add_alt_1_rounded,
            size: 28,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Add New User',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in the details below to create a new account',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField({
    required this.controller,
    required this.colorScheme,
  });
  final TextEditingController controller;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Enter username',
        prefixIcon: Icon(Icons.person_outline_rounded, color: colorScheme.onSurfaceVariant),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Username is required';
        }
        if (v.trim().length < 4) {
          return 'Username must be at least 4 characters';
        }
        return null;
      },
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({
    required this.controller,
    required this.colorScheme,
  });
  final TextEditingController controller;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter email address',
        prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Email is required';
        }
        if (!v.contains('@') || !v.contains('.')) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.colorScheme,
  });
  final TextEditingController controller;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Phone',
        hintText: 'Enter phone number',
        prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.onSurfaceVariant),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Phone number is required';
        }
        if (!RegExp(r'^\d{10,15}$').hasMatch(v.trim())) {
          return 'Enter a valid phone number (10-15 digits)';
        }
        return null;
      },
    );
  }
}

class _FullNameField extends StatelessWidget {
  const _FullNameField({
    required this.controller,
    required this.colorScheme,
  });
  final TextEditingController controller;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter full name',
        prefixIcon: Icon(Icons.badge_outlined, color: colorScheme.onSurfaceVariant),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Full name is required';
        }
        if (v.trim().length < 4) {
          return 'Full name must be at least 4 characters';
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.colorScheme,
  });
  final TextEditingController controller;
  final ColorScheme colorScheme;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _onSubmit(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter password',
        prefixIcon: Icon(Icons.lock_outline_rounded, color: widget.colorScheme.onSurfaceVariant),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: widget.colorScheme.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Password is required';
        }
        if (v.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  void _onSubmit() {
    final form = context.findAncestorStateOfType<FormState>();
    form?.save();
  }
}

class _RoleDropdown extends ConsumerStatefulWidget {
  const _RoleDropdown({
    required this.initialValue,
    required this.onChanged,
    required this.colorScheme,
  });

  final String initialValue;
  final ValueChanged<String?> onChanged;
  final ColorScheme colorScheme;

  @override
  ConsumerState<_RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends ConsumerState<_RoleDropdown> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedValue,
      decoration: InputDecoration(
        labelText: 'Role',
        prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: widget.colorScheme.onSurfaceVariant),
      ),
      items: const [
        DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
        DropdownMenuItem(value: 'management', child: Text('Management')),
        DropdownMenuItem(value: 'principal', child: Text('Principal')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedValue = value);
          widget.onChanged(value);
        }
      },
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isLoading,
    required this.onPressed,
    required this.colorScheme,
  });
  final bool isLoading;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              )
            : const Text(
                'Create User',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
      ),
    );
  }
}