import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/network/dio_client.dart';
import 'package:cms/features/fees/presentation/screens/fee_home_screen.dart';
import 'package:cms/features/auth/data/models/auth_user.dart';
import 'package:cms/features/auth/presentation/screens/login_screen.dart';
import 'package:cms/features/auth/presentation/screens/register_screen.dart';
import 'package:cms/features/dashboard/presentation/widgets/admin_dashboard_body.dart';
import 'package:cms/features/dashboard/presentation/widgets/teacher_dashboard_body.dart';
import 'package:cms/features/students/presentation/screens/student_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:cms/features/classes/presentation/screens/class_management_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/staff/presentation/screens/staff_management_screen.dart';
import 'package:cms/features/subjects/presentation/screens/subject_management_screen.dart';
import 'package:cms/features/teachers/presentation/screens/teacher_management_screen.dart';
import 'package:cms/features/lectures/presentation/screens/lecture_management_screen.dart';
import 'package:cms/features/attendance/presentation/screens/attendance_home_screen.dart';
import 'package:cms/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:cms/features/ai/presentation/screens/ai_assistant_screen.dart';
import 'package:cms/features/exams/presentation/screens/management_exams_screen.dart';
import 'package:cms/features/reports/presentation/screens/reports_hub_screen.dart';
import 'package:cms/core/theme/app_colors.dart';

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
    final bool canAccessAi = isAdmin || user.role == 'teacher';
    final bool isCampusUser = canAccessAi;
    final compact = MediaQuery.sizeOf(context).width < 480;
    return AppBar(
      backgroundColor: isCampusUser ? const Color(0xFFF4F1FC) : null,
      foregroundColor: isCampusUser ? CampusStyle.ink : null,
      surfaceTintColor: isCampusUser ? Colors.transparent : null,
      elevation: 0,
      toolbarHeight: compact
          ? kToolbarHeight
          : isCampusUser
          ? 72
          : kToolbarHeight,
      centerTitle: false,
      titleSpacing: compact
          ? 8
          : isCampusUser
          ? 12
          : null,
      leadingWidth: isAdmin ? (compact ? 56 : 68) : null,
      iconTheme: isCampusUser
          ? const IconThemeData(color: CampusStyle.primary)
          : null,
      actionsIconTheme: isCampusUser
          ? const IconThemeData(color: CampusStyle.primary)
          : null,
      title: isCampusUser
          ? (compact
                ? Tooltip(
                    message: user.fullName,
                    child: Text(
                      user.fullName,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CampusStyle.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : _dashboardIdentity())
          : Text(
              'Welcome, ${user.fullName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      leading: isAdmin
          ? Builder(
              builder: (context) => Center(
                child: IconButton(
                  tooltip: 'Open navigation menu',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE1DDF5),
                    foregroundColor: CampusStyle.primary,
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Color(0xFFC9C8E8)),
                  ),
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: CampusStyle.primary,
                    size: 26,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            )
          : null,
      actions: [
        if (canAccessAi && !compact)
          IconButton(
            tooltip: 'AI Assistant',
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
              );
            },
          ),
        IconButtonTheme(
          data: IconButtonThemeData(
            style: IconButton.styleFrom(
              foregroundColor: isCampusUser
                  ? CampusStyle.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: const NotificationBell(),
        ),
        if (compact)
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: const Icon(Icons.more_vert, color: CampusStyle.primary),
            onSelected: (action) {
              if (action == 'ai') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                );
              } else if (action == 'logout') {
                _logout(context, ref);
              }
            },
            itemBuilder: (_) => [
              if (canAccessAi)
                const PopupMenuItem(value: 'ai', child: Text('AI Assistant')),
              const PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
          ),
        if (!compact)
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _logout(context, ref),
            icon: Icon(
              Icons.logout,
              color: isCampusUser ? CampusStyle.primary : null,
            ),
          ),
      ],
    );
  }

  Widget _dashboardIdentity() => Tooltip(
    message: user.fullName,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.role == 'principal'
              ? 'PRINCIPAL • CITY IDEAL SCHOOL'
              : user.role == 'teacher'
              ? 'TEACHER • CITY IDEAL SCHOOL'
              : 'ADMINISTRATION • CITY IDEAL SCHOOL',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: CampusStyle.accent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: CampusStyle.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAdmin = user.role == 'management' || user.role == 'principal';
    final dashboard = Theme(
      data: Theme.of(context),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: _buildAppBar(context, ref),
          drawer: isAdmin
              ? SafeArea(
                  child: Material(
                    color: const Color(0xFFF4F1FC),
                    child: SizedBox(
                      width: 280,
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
                                    'City Ideal School',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
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
                                  leading: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppColors.primary,
                                  ),
                                  title: const Text(
                                    'AI Assistant',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AiAssistantScreen(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.person_add_alt_1_rounded,
                                  ),
                                  title: const Text('Create User'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.fact_check_outlined,
                                  ),
                                  title: const Text('Attendance'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AttendanceHomeScreen(
                                          isPrincipalReadOnly:
                                              user.role == 'principal',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.payments_outlined),
                                  title: const Text('Fees'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const FeeHomeScreen(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.assignment_turned_in_outlined,
                                  ),
                                  title: const Text('Exams & Results'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ManagementExamsScreen(
                                          isPrincipalReadOnly:
                                              user.role == 'principal',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.analytics_outlined),
                                  title: const Text('Reports & Analytics'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ReportsHubScreen(),
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
                                      leading: const Icon(
                                        Icons.people_alt_rounded,
                                      ),
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
                                      leading: const Icon(
                                        Icons.menu_book_outlined,
                                      ),
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
                                    ListTile(
                                      contentPadding: const EdgeInsets.only(
                                        left: 32,
                                        right: 16,
                                      ),
                                      leading: const Icon(
                                        Icons.school_outlined,
                                      ),
                                      title: const Text('Teachers'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const TeacherManagementScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      contentPadding: const EdgeInsets.only(
                                        left: 32,
                                        right: 16,
                                      ),
                                      leading: const Icon(
                                        Icons.event_note_outlined,
                                      ),
                                      title: const Text('Lectures'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const LectureManagementScreen(),
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
                  ),
                )
              : null,
          body: isAdmin || user.role == 'teacher'
              ? Stack(
                  children: [
                    const Positioned.fill(child: CampusBackground()),
                    SafeArea(child: _bodyForRole(user.role)),
                  ],
                )
              : _bodyForRole(user.role),
        ),
      ),
    );
    return dashboard;
  }

  Widget _bodyForRole(String role) {
    switch (role) {
      case 'management':
      case 'principal':
        return AdminDashboardBody(isPrincipalReadOnly: role == 'principal');
      case 'teacher':
        return const TeacherDashboardBody();
      default:
        return const Center(child: Text('Unknown role'));
    }
  }
}
