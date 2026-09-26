import 'package:cms/features/subjects/application/all_students_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/staff/application/all_staff_list_controller.dart';
import 'package:cms/features/classes/application/classes_list_controller.dart';
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
    final studentsAsync = ref.watch(allStudentsControllerProvider);
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final staffAsync = ref.watch(allStaffListControllerProvider);
    final classesAsync = ref.watch(classesListControllerProvider(page: 1));
    final subjectsAsync = ref.watch(subjectsListControllerProvider);
    final feeSummaryAsync = ref.watch(feeSummaryControllerProvider());
    final feeDefaultersAsync = ref.watch(feeDefaultersControllerProvider());
    final attendanceDefaultersAsync = ref.watch(
      defaultersControllerProvider(threshold: 75.0, dateFrom: _rangeFrom, dateTo: _rangeTo),
    );
    final unreadAsync = ref.watch(unreadNotificationsControllerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allStudentsControllerProvider);
        ref.invalidate(teachersListControllerProvider);
        ref.invalidate(allStaffListControllerProvider);
        ref.invalidate(classesListControllerProvider);
        ref.invalidate(subjectsListControllerProvider);
        ref.invalidate(feeSummaryControllerProvider);
        ref.invalidate(feeDefaultersControllerProvider);
        ref.invalidate(defaultersControllerProvider);
        ref.invalidate(unreadNotificationsControllerProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DashboardStatCard(
                  icon: Icons.groups_outlined,
                  label: 'Students',
                  value: '${studentsAsync.valueOrNull?.length ?? 0}',
                  color: Colors.indigo,
                  isLoading: studentsAsync.isLoading,
                  hasError: studentsAsync.hasError,
                ),
                DashboardStatCard(
                  icon: Icons.school_outlined,
                  label: 'Teachers',
                  value: '${teachersAsync.valueOrNull?.length ?? 0}',
                  color: Colors.teal,
                  isLoading: teachersAsync.isLoading,
                  hasError: teachersAsync.hasError,
                ),
                DashboardStatCard(
                  icon: Icons.badge_outlined,
                  label: 'Staff',
                  value: '${staffAsync.valueOrNull?.length ?? 0}',
                  color: Colors.brown,
                  isLoading: staffAsync.isLoading,
                  hasError: staffAsync.hasError,
                ),
                DashboardStatCard(
                  icon: Icons.class_outlined,
                  label: 'Classes',
                  value: '${classesAsync.valueOrNull?.length ?? 0}',
                  color: Colors.deepPurple,
                  isLoading: classesAsync.isLoading,
                  hasError: classesAsync.hasError,
                ),
                DashboardStatCard(
                  icon: Icons.menu_book_outlined,
                  label: 'Subjects',
                  value: '${subjectsAsync.valueOrNull?.length ?? 0}',
                  color: Colors.blueGrey,
                  isLoading: subjectsAsync.isLoading,
                  hasError: subjectsAsync.hasError,
                ),
                DashboardStatCard(
                  icon: Icons.percent_rounded,
                  label: 'Fee Collection',
                  value: feeSummaryAsync.valueOrNull != null
                      ? '${feeSummaryAsync.valueOrNull!.summary.collectionEfficiency.toStringAsFixed(0)}%'
                      : '0%',
                  color: Colors.green,
                  isLoading: feeSummaryAsync.isLoading,
                  hasError: feeSummaryAsync.hasError,
                ),
                DashboardStatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Fee Defaulters',
                  value: '${feeDefaultersAsync.valueOrNull?.count ?? 0}',
                  color: Colors.red,
                  isLoading: feeDefaultersAsync.isLoading,
                  hasError: feeDefaultersAsync.hasError,
                ),
                DashboardStatCard(
                  icon: Icons.event_busy_outlined,
                  label: 'Attendance <75% (30d)',
                  value: '${attendanceDefaultersAsync.valueOrNull?.defaulters.length ?? 0}',
                  color: Colors.orange,
                  isLoading: attendanceDefaultersAsync.isLoading,
                  hasError: attendanceDefaultersAsync.hasError,
                ),
                DashboardStatCard(
                  icon: Icons.notifications_outlined,
                  label: 'Unread Alerts',
                  value: '${unreadAsync.valueOrNull?.length ?? 0}',
                  color: Colors.blue,
                  isLoading: unreadAsync.isLoading,
                  hasError: unreadAsync.hasError,
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('Quick Access',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / 150).floor().clamp(2, 6);
                final shortcuts = <Widget>[
                  DashboardShortcutTile(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Create User',
                    onTap: () => _push(const RegisterScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.people_alt_rounded,
                    label: 'Students',
                    onTap: () => _push(const StudentManagementScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.badge_outlined,
                    label: 'Staff',
                    onTap: () => _push(const StaffManagementScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.class_outlined,
                    label: 'Classes',
                    onTap: () => _push(const ClassManagementScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Subjects',
                    onTap: () => _push(const SubjectManagementScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.school_outlined,
                    label: 'Teachers',
                    onTap: () => _push(const TeacherManagementScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.event_note_outlined,
                    label: 'Lectures',
                    onTap: () => _push(const LectureManagementScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.calendar_month_outlined,
                    label: 'Schedule',
                    onTap: () => _push(const ScheduleScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.event_outlined,
                    label: 'Calendar',
                    onTap: () => _push(const CalendarScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.fact_check_outlined,
                    label: 'Attendance',
                    onTap: () => _push(const AttendanceHomeScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.payments_outlined,
                    label: 'Fees',
                    onTap: () => _push(const FeeHomeScreen()),
                  ),
                  DashboardShortcutTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => _push(const NotificationsScreen()),
                  ),
                ];
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: shortcuts,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}