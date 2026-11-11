import 'package:cms/features/attendance/application/teacher_biometric_attendance_providers.dart';
import 'package:cms/features/attendance/data/models/teacher_attendance_models.dart';
import 'package:cms/features/attendance/presentation/screens/attendance_devices_screen.dart';
import 'package:cms/features/attendance/presentation/screens/attendance_home_screen.dart';
import 'package:cms/features/attendance/presentation/screens/attendance_policy_screen.dart';
import 'package:cms/features/attendance/presentation/screens/teacher_daily_attendance_screen.dart';
import 'package:cms/features/attendance/presentation/screens/teacher_enrollment_screen.dart';
import 'package:cms/features/attendance/presentation/screens/teacher_kiosk_screen.dart';
import 'package:cms/features/attendance/services/biometric_scanner_service.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAllClassesController extends AllClassesController {
  @override
  Future<List<SchoolClass>> build() async => const [];
}

class _FakeScannerAdapter implements BiometricScannerAdapter {
  @override
  Future<ScannerConnectionStatus> checkConnection() async =>
      const ScannerConnectionStatus(
        isReady: true,
        isHardwareSdkAttached: false,
        adapterName: 'Test Adapter',
        statusDetail: 'Ready',
      );

  @override
  Future<void> deleteLocalTemplate({
    required String teacherId,
    required String deviceId,
  }) async {}

  @override
  Future<CapturedTemplateResult> enrollTeacherTemplate({
    required String teacherId,
    required String teacherName,
    required String deviceId,
  }) async =>
      const CapturedTemplateResult(
        templateReference: 'tpl_test',
        templateVersion: 'v1',
      );

  @override
  Future<List<LocalTemplateRecord>> listLocalTemplates(String deviceId) async =>
      const [];

  @override
  Future<LocalTemplateRecord?> matchTeacherLocally({
    required String deviceId,
    required String teacherId,
  }) async =>
      null;
}

class _StubTeachersController extends TeachersListController {
  @override
  Future<List<Teacher>> build() async => [
        Teacher(
          id: 't-1',
          userId: 'u-1',
          fullName: 'Sara Ahmed',
          email: 'sara@step.edu',
          department: 'Mathematics',
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
}

List<Override> _testOverrides() {
  final sampleDevice = AttendanceDevice(
    id: 'dev-1',
    deviceName: 'Front Kiosk',
    deviceIdentifier: 'kiosk-01',
    deviceModel: 'ZK4500',
    isActive: true,
    registeredAt: DateTime(2026, 11, 11, 7, 30),
  );
  return [
    allClassesControllerProvider.overrideWith(_StubAllClassesController.new),
    biometricScannerAdapterProvider.overrideWithValue(_FakeScannerAdapter()),
    teachersListControllerProvider.overrideWith(_StubTeachersController.new),
    attendanceDevicesProvider.overrideWith((ref) async => [sampleDevice]),
    attendancePolicyProvider.overrideWith(
      (ref) async => [AttendancePolicyDay.defaultForDay(0)],
    ),
    teacherDailyAttendanceProvider.overrideWith(
      (ref, dateIso) async => [
        TeacherDailyAttendanceItem(
          attendanceId: 'att-1',
          teacherId: 't-1',
          teacherName: 'Sara Ahmed',
          date: dateIso,
          status: 'late',
          checkInAt: DateTime.utc(2026, 11, 11, 3, 15),
          checkOutAt: DateTime.utc(2026, 11, 11, 8, 10),
          shortLeave: true,
          checkInSource: 'fingerprint',
          checkOutSource: 'manual',
        ),
      ],
    ),
    teacherAttendanceSummaryProvider.overrideWith(
      (ref, range) async => TeacherAttendanceSummary(
        dateFrom: range.dateFromIso,
        dateTo: range.dateToIso,
        totalRecords: 12,
        present: 8,
        late: 2,
        absent: 1,
        leave: 1,
        shortLeave: 1,
      ),
    ),
    teacherEnrollmentsProvider.overrideWith(
      (ref, teacherId) async => [
        FingerprintEnrollment(
          id: 'enr-1',
          teacherId: teacherId,
          deviceId: 'dev-1',
          templateReference: 'tpl_abc',
          templateVersion: 'v1',
          isActive: true,
          enrolledAt: DateTime(2026, 11, 11, 7, 35),
        ),
      ],
    ),
  ];
}

void main() {
  testWidgets('TeacherDailyAttendanceScreen renders daily rows & summary tab on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: _testOverrides(),
        child: const MaterialApp(home: TeacherDailyAttendanceScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sara Ahmed', skipOffstage: false), findsWidgets);
    expect(find.text('Short Leave'), findsOneWidget);

    await tester.tap(find.text('Period Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Total Records'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('TeacherDailyAttendanceScreen renders DataTable & summary on desktop', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: _testOverrides(),
        child: const MaterialApp(home: TeacherDailyAttendanceScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sara Ahmed', skipOffstage: false), findsWidgets);
    expect(find.text('Short Leave'), findsNWidgets(2));

    await tester.tap(find.text('Period Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Total Records'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('TeacherKioskScreen renders Arrival/Departure toggles without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: _testOverrides(),
        child: const MaterialApp(home: TeacherKioskScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ARRIVAL'), findsOneWidget);
    expect(find.text('DEPARTURE'), findsOneWidget);
    await tester.tap(find.text('DEPARTURE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Departure'), findsWidgets);
  });

  testWidgets('AttendanceDevicesScreen, TeacherEnrollmentScreen, AttendancePolicyScreen, AttendanceHomeScreen render cleanly on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final screen in const [
      AttendanceDevicesScreen(),
      TeacherEnrollmentScreen(),
      AttendancePolicyScreen(),
      AttendanceHomeScreen(),
    ]) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _testOverrides(),
          child: MaterialApp(home: screen),
        ),
      );
      await tester.pumpAndSettle();
    }
  });
}
