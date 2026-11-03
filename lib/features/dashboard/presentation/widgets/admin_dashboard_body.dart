import 'package:cms/features/dashboard/application/dashboard_counts_provider.dart';
import 'package:cms/features/subjects/application/all_students_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/staff/application/all_staff_list_controller.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import 'package:cms/features/subjects/application/subjects_list_controller.dart';
import 'package:cms/features/fees/application/fee_summary_controller.dart';
import 'package:cms/features/fees/application/fee_defaulters_controller.dart';
import 'package:cms/features/attendance/application/defaulters_controller.dart';
import 'package:cms/features/notifications/application/unread_notifications_controller.dart';
import 'package:cms/features/auth/presentation/screens/register_screen.dart';
import 'package:cms/features/students/presentation/screens/student_management_screen.dart';
import 'package:cms/features/staff/presentation/screens/staff_management_screen.dart';
import 'package:cms/features/classes/presentation/screens/class_management_screen.dart';
import 'package:cms/features/subjects/presentation/screens/subject_management_screen.dart';
import 'package:cms/features/teachers/presentation/screens/teacher_management_screen.dart';
import 'package:cms/features/lectures/presentation/screens/lecture_management_screen.dart';
import 'package:cms/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:cms/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:cms/features/attendance/presentation/screens/attendance_home_screen.dart';
import 'package:cms/features/fees/presentation/screens/fee_home_screen.dart';
import 'package:cms/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:cms/features/ai/presentation/screens/ai_assistant_screen.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/dashboard_shortcut_tile.dart';

class AdminDashboardBody extends ConsumerStatefulWidget {
  const AdminDashboardBody({super.key});

  @override
  ConsumerState<AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends ConsumerState<AdminDashboardBody> {
  // Computed once — a date-range family provider must never get a fresh
  // DateTime.now() on every rebuild (same bug class fixed earlier on Schedule).
  late final DateTime _rangeFrom;
  late final DateTime _rangeTo;

  @override
  void initState() {
    super.initState();
    _rangeTo = DateTime.now();
    _rangeFrom = _rangeTo.subtract(const Duration(days: 30));
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(dashboardCountsProvider);
    final feeSummaryAsync = ref.watch(feeSummaryControllerProvider());
    final feeDefaultersAsync = ref.watch(feeDefaultersControllerProvider());
    final attendanceDefaultersAsync = ref.watch(
      defaultersControllerProvider(
        threshold: 75.0,
        dateFrom: _rangeFrom,
        dateTo: _rangeTo,
      ),
    );
    final unreadAsync = ref.watch(unreadNotificationsControllerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardCountsProvider);
        ref.invalidate(allStudentsControllerProvider);
        ref.invalidate(teachersListControllerProvider);
        ref.invalidate(allStaffListControllerProvider);
        ref.invalidate(allClassesControllerProvider);
        ref.invalidate(subjectsListControllerProvider);
        ref.invalidate(feeSummaryControllerProvider);
        ref.invalidate(feeDefaultersControllerProvider);
        ref.invalidate(defaultersControllerProvider);
        ref.invalidate(unreadNotificationsControllerProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 480 ? 16 : 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1192),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF253E7A), Color(0xFF554490)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x20253E7A),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP ACADEMY  /  ADMINISTRATION',
                        style: TextStyle(
                          color: Color(0xFFD9DFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your campus, at a glance.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Manage your people, plan classes, and keep track of campus activity.',
                        style: TextStyle(
                          color: Color(0xFFE2E6FF),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Campus overview',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = (constraints.maxWidth / 190).floor().clamp(
                      1,
                      5,
                    );
                    final cardWidth =
                        (constraints.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        DashboardStatCard(
                          width: cardWidth,
                          icon: Icons.groups_outlined,
                          label:
                              'Students • ${countsAsync.valueOrNull?['students'] ?? 0} active',
                          value:
                              '${countsAsync.valueOrNull?['students_total'] ?? countsAsync.valueOrNull?['students'] ?? 0}',
                          color: const Color(0xFF5458B5),
                          isLoading: countsAsync.isLoading,
                          hasError: countsAsync.hasError,
                        ),
                        DashboardStatCard(
                          width: cardWidth,
                          icon: Icons.school_outlined,
                          label: 'Teachers',
                          value: '${countsAsync.valueOrNull?['teachers'] ?? 0}',
                          color: const Color(0xFF326DA0),
                          isLoading: countsAsync.isLoading,
                          hasError: countsAsync.hasError,
                        ),
                        DashboardStatCard(
                          width: cardWidth,
                          icon: Icons.badge_outlined,
                          label: 'Staff',
                          value: '${countsAsync.valueOrNull?['staff'] ?? 0}',
                          color: const Color(0xFF7856A6),
                          isLoading: countsAsync.isLoading,
                          hasError: countsAsync.hasError,
                        ),
                        DashboardStatCard(
                          width: cardWidth,
                          icon: Icons.class_outlined,
                          label: 'Classes',
                          value: '${countsAsync.valueOrNull?['classes'] ?? 0}',
                          color: CampusStyle.primary,
                          isLoading: countsAsync.isLoading,
                          hasError: countsAsync.hasError,
                        ),
                        DashboardStatCard(
                          width: cardWidth,
                          icon: Icons.menu_book_outlined,
                          label: 'Subjects',
                          value: '${countsAsync.valueOrNull?['subjects'] ?? 0}',
                          color: const Color(0xFF326DA0),
                          isLoading: countsAsync.isLoading,
                          hasError: countsAsync.hasError,
                        ),
                        DashboardStatCard(
                          width: cardWidth,
                          icon: Icons.percent_rounded,
                          label: 'Fee Collection',
                          value: feeSummaryAsync.valueOrNull != null
                              ? '${feeSummaryAsync.valueOrNull!.summary.collectionEfficiency.toStringAsFixed(0)}%'
                              : '0%',
                          color: const Color(0xFF287B70),
                          isLoading: feeSummaryAsync.isLoading,
                          hasError: feeSummaryAsync.hasError,
                        ),
                        DashboardStatCard(
                          width: cardWidth,
                          icon: Icons.warning_amber_rounded,
                          label: 'Fee Defaulters',
                          value:
                              '${feeDefaultersAsync.valueOrNull?.count ?? 0}',
                          color: const Color(0xFFAF4C64),
                          isLoading: feeDefaultersAsync.isLoading,
                          hasError: feeDefaultersAsync.hasError,
                        ),
                        DashboardStatCard(
                          width: cardWidth,
                          icon: Icons.event_busy_outlined,
                          label: 'Attendance <75% (30d)',
                          value:
                              '${attendanceDefaultersAsync.valueOrNull?.defaulters.length ?? 0}',
                          color: const Color(0xFF94651D),
                          isLoading: attendanceDefaultersAsync.isLoading,
                          hasError: attendanceDefaultersAsync.hasError,
                        ),
                        DashboardStatCard(
                          width: cardWidth,
                          icon: Icons.notifications_outlined,
                          label: 'Unread Alerts',
                          value: '${unreadAsync.valueOrNull?.length ?? 0}',
                          color: const Color(0xFF326DA0),
                          isLoading: unreadAsync.isLoading,
                          hasError: unreadAsync.hasError,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Campus workspace',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = (constraints.maxWidth / 190)
                        .floor()
                        .clamp(1, 5);
                    final shortcuts = <Widget>[
                      DashboardShortcutTile(
                        icon: Icons.auto_awesome_rounded,
                        label: 'AI Assistant',
                        color: CampusStyle.primary,
                        onTap: () => _push(const AiAssistantScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.person_add_alt_1_rounded,
                        label: 'Create User',
                        color: const Color(0xFF326DA0),
                        onTap: () => _push(const RegisterScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.people_alt_rounded,
                        label: 'Students',
                        color: const Color(0xFF5458B5),
                        onTap: () => _push(const StudentManagementScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.badge_outlined,
                        label: 'Staff',
                        color: const Color(0xFF7856A6),
                        onTap: () => _push(const StaffManagementScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.class_outlined,
                        label: 'Classes',
                        color: CampusStyle.accent,
                        onTap: () => _push(const ClassManagementScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.menu_book_outlined,
                        label: 'Subjects',
                        color: const Color(0xFF326DA0),
                        onTap: () => _push(const SubjectManagementScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.school_outlined,
                        label: 'Teachers',
                        color: const Color(0xFF326DA0),
                        onTap: () => _push(const TeacherManagementScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.event_note_outlined,
                        label: 'Lectures',
                        color: const Color(0xFF6250B8),
                        onTap: () => _push(const LectureManagementScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.calendar_month_outlined,
                        label: 'Schedule',
                        color: const Color(0xFF326DA0),
                        onTap: () => _push(const ScheduleScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.event_outlined,
                        label: 'Calendar',
                        color: const Color(0xFF7856A6),
                        onTap: () => _push(const CalendarScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.fact_check_outlined,
                        label: 'Attendance',
                        color: const Color(0xFF287B70),
                        onTap: () => _push(const AttendanceHomeScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.payments_outlined,
                        label: 'Fees',
                        color: const Color(0xFF326DA0),
                        onTap: () => _push(const FeeHomeScreen()),
                      ),
                      DashboardShortcutTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        color: const Color(0xFF94651D),
                        onTap: () => _push(const NotificationsScreen()),
                      ),
                    ];
                    final tileWidth =
                        (constraints.maxWidth - (crossAxisCount - 1) * 12) /
                        crossAxisCount;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: shortcuts
                          .map(
                            (tile) => SizedBox(width: tileWidth, child: tile),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
