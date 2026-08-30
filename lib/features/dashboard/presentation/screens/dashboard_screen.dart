import 'package:cms/core/network/dio_client.dart';
import 'package:cms/features/auth/data/models/auth_user.dart';
import 'package:cms/features/auth/presentation/screens/login_screen.dart';
import 'package:cms/features/auth/presentation/screens/register_screen.dart';
import 'package:cms/features/dashboard/presentation/widgets/admin_dashboard_body.dart';
import 'package:cms/features/students/presentation/screens/student_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:cms/features/classes/presentation/screens/class_management_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/staff/presentation/screens/staff_management_screen.dart';
import 'package:cms/features/subjects/presentation/screens/subject_management_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final AuthUser user;

  const DashboardScreen({super.key, required this.user});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(secureStorageProvider).clearToken();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final bool isAdmin = user.role == 'management' || user.role == 'principal';
    return AppBar(
      title: Text("Welcome, ${user.fullName}"),
      leading: isAdmin
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      actions: [
        IconButton(
          onPressed: () => _logout(context, ref),
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAdmin = user.role == 'management' || user.role == 'principal';
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      drawer: isAdmin
          ? SafeArea(
              child: Container(
                width: 250,
                child: Column(
                  children: [
                    // Header
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Icon(
                            //   Icons.school_rounded,
                            //   size: 32,
                            //   color: Colors.deepPurple,
                            // ),
                            const SizedBox(height: 32),
                            Text(
                              'STEP CMS',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Admin Panel',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person_add_alt_1_rounded),
                            title: const Text('User+'),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                          ),
                          ExpansionTile(
                            leading: const Icon(Icons.apartment_rounded),
                            title: const Text('Campus'),
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 32,
                                  right: 16,
                                ),
                                leading: const Icon(Icons.people_alt_rounded),
                                title: const Text('Students'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const StudentManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 32,
                                  right: 16,
                                ),
                                leading: const Icon(Icons.badge_outlined),
                                title: const Text('Staff'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const StaffManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 32,
                                  right: 16,
                                ),
                                leading: const Icon(Icons.class_outlined),
                                title: const Text('Classes'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ClassManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 32,
                                  right: 16,
                                ),
                                leading: const Icon(Icons.menu_book_outlined),
                                title: const Text('Subjects'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SubjectManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: _bodyForRole(user.role),
    );
  }

  Widget _bodyForRole(String role) {
    switch (role) {
      case 'management':
      case 'principal':
        return const AdminDashboardBody();
      case 'teacher':
        return const Center(child: Text('Teacher dashboard — coming next'));
      default:
        return const Center(child: Text('Unknown role'));
    }
  }
}
