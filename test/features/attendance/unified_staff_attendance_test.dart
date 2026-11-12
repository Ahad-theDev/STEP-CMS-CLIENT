import 'dart:convert';
import 'dart:typed_data';

import 'package:cms/features/attendance/application/staff_attendance_list_controller.dart';
import 'package:cms/features/attendance/data/models/bulk_staff_attendance_entry.dart';
import 'package:cms/features/attendance/data/models/bulk_staff_attendance_request.dart';
import 'package:cms/features/attendance/data/models/bulk_staff_attendance_response.dart';
import 'package:cms/features/attendance/data/models/staff_attendance.dart';
import 'package:cms/features/attendance/data/models/staff_attendance_mark_request.dart';
import 'package:cms/features/attendance/data/models/staff_attendance_unified_models.dart';
import 'package:cms/features/attendance/data/staff_attendance_repository.dart';
import 'package:cms/features/attendance/presentation/screens/mark_staff_attendance_screen.dart';
import 'package:cms/features/attendance/presentation/screens/staff_attendance_list_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  dynamic Function(RequestOptions options)? handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final payload = handler != null ? handler!(options) : {};
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

List<Override> _unifiedOverrides() {
  final roster = [
    StaffAttendanceRosterItem(
      personId: 't-1',
      personType: 'teacher',
      personName: 'Sara Ahmed',
      designation: 'Teacher',
      attendanceId: 'att-1',
      date: '2026-11-12',
      status: 'late',
      checkInAt: DateTime(2026, 11, 12, 8, 25),
      checkOutAt: DateTime(2026, 11, 12, 13, 30),
      shortLeave: true,
      checkInSource: 'biometric',
      checkOutSource: 'manual',
      isMarked: true,
    ),
    const StaffAttendanceRosterItem(
      personId: 's-1',
      personType: 'staff',
      personName: 'Imran Clerk',
      designation: 'Office Clerk',
      attendanceId: null,
      date: '2026-11-12',
      status: null,
      checkInAt: null,
      checkOutAt: null,
      shortLeave: false,
      checkInSource: null,
      checkOutSource: null,
      isMarked: false,
    ),
  ];

  final savedRecords = [
    StaffAttendance(
      id: 'att-1',
      teacherId: 't-1',
      personId: 't-1',
      personName: 'Sara Ahmed',
      personType: 'teacher',
      designation: 'Teacher',
      date: '2026-11-12',
      status: 'late',
      checkInAt: DateTime(2026, 11, 12, 8, 25),
      checkOutAt: DateTime(2026, 11, 12, 13, 30),
      shortLeave: true,
      checkInSource: 'biometric',
      checkOutSource: 'manual',
      isMarked: true,
    ),
  ];

  const summary = StaffAttendanceSummaryResponse(
    dateFrom: '2026-10-14',
    dateTo: '2026-11-12',
    totalRecords: 14,
    present: 10,
    late: 2,
    absent: 1,
    leave: 1,
    shortLeaveDays: 2,
    checkInCount: 12,
    checkOutCount: 11,
    incompleteCheckouts: 1,
    totalWorkedMinutes: 5400,
    attendancePercentage: 85.7,
    peopleWithRecords: 2,
    people: [
      StaffPersonSummary(
        personId: 't-1',
        personType: 'teacher',
        personName: 'Sara Ahmed',
        totalRecords: 10,
        present: 8,
        late: 2,
        absent: 0,
        leave: 0,
        shortLeaveDays: 1,
        checkInCount: 10,
        checkOutCount: 9,
        incompleteCheckouts: 1,
        totalWorkedMinutes: 4200,
        attendancePercentage: 100.0,
      ),
    ],
    summaryBasis: 'saved_records_only',
  );

  return [
    staffAttendanceRosterProvider.overrideWith((ref, dateIso) async => roster),
    staffAttendanceListProvider.overrideWith(
      (ref, filter) async => savedRecords,
    ),
    staffAttendanceSummaryProvider.overrideWith(
      (ref, filter) async => summary,
    ),
  ];
}

void main() {
  group('Unified Staff Attendance Models', () {
    test('StaffAttendanceRosterItem parses unmarked and marked entries', () {
      final unmarked = StaffAttendanceRosterItem.fromJson({
        'person_id': 's-1',
        'person_type': 'staff',
        'person_name': 'Bano Clerk',
        'designation': 'Clerk',
        'attendance_id': null,
        'date': '2026-11-12',
        'status': null,
        'check_in_at': null,
        'check_out_at': null,
        'short_leave': false,
        'is_marked': false,
      });
      expect(unmarked.isMarked, isFalse);
      expect(unmarked.status, isNull);
      expect(unmarked.rosterKey, 'staff:s-1');
    });

    test('StaffAttendanceMarkRequest respects check-in/out vs absent rules', () {
      final checkInReq = StaffAttendanceMarkRequest(
        personType: 'teacher',
        personId: 't-1',
        date: '2026-11-12',
        checkInAt: DateTime(2026, 11, 12, 8, 10),
        checkOutAt: DateTime(2026, 11, 12, 14, 0),
        shortLeave: false,
      );
      final checkInJson = checkInReq.toJson();
      expect(checkInJson.containsKey('status'), isFalse);
      expect(checkInJson['check_in_at'], contains('T08:10:00'));
      expect(checkInJson['check_out_at'], contains('T14:00:00'));
      expect(checkInJson['check_in_at'], matches(RegExp(r'[+-]\d{2}:\d{2}$')));

      const absentReq = StaffAttendanceMarkRequest(
        personType: 'staff',
        personId: 's-1',
        date: '2026-11-12',
        status: 'absent',
        reason: 'Uninformed absence',
      );
      final absentJson = absentReq.toJson();
      expect(absentJson['status'], 'absent');
      expect(absentJson.containsKey('check_in_at'), isFalse);
      expect(absentJson.containsKey('check_out_at'), isFalse);
      expect(absentJson['reason'], 'Uninformed absence');
    });

    test('BulkStaffAttendanceRequest and EditRequest serialize accurately', () {
      final bulkReq = BulkStaffAttendanceRequest(
        date: '2026-11-12',
        defaultCheckInAt: DateTime(2026, 11, 12, 8, 0),
        defaultCheckOutAt: DateTime(2026, 11, 12, 14, 0),
        entries: [
          BulkStaffAttendanceEntry(
            personType: 'teacher',
            personId: 't-1',
            checkInAt: DateTime(2026, 11, 12, 8, 30),
          ),
          const BulkStaffAttendanceEntry(
            personType: 'staff',
            personId: 's-1',
            status: 'leave',
          ),
        ],
      );
      final bulkJson = bulkReq.toJson();
      expect(bulkJson['default_check_in_at'], contains('T08:00:00'));
      expect((bulkJson['entries'] as List).length, 2);
      expect((bulkJson['entries'] as List)[1]['status'], 'leave');
      expect((bulkJson['entries'] as List)[1].containsKey('check_in_at'), isFalse);

      final bulkResp = BulkStaffAttendanceResponse.fromJson({
        'date': '2026-11-12',
        'saved_count': 2,
        'results': [
          {
            'person_id': 't-1',
            'person_type': 'teacher',
            'attendance_id': 'att-1',
            'action': 'created',
          },
        ],
      });
      expect(bulkResp.savedCount, 2);
      expect(bulkResp.results.single.attendanceId, 'att-1');

      const editReq = StaffAttendanceEditRequest(
        clearCheckOut: true,
        shortLeave: false,
        reason: 'Removed accidental checkout punch',
      );
      final editJson = editReq.toJson();
      expect(editJson.containsKey('check_out_at'), isTrue);
      expect(editJson['check_out_at'], isNull);
      expect(editJson['short_leave'], isFalse);
      expect(editJson['reason'], 'Removed accidental checkout punch');
    });

    test('Audit and Summary responses parse snapshots and worked minutes', () {
      final audit = StaffAttendanceAuditItem.fromJson({
        'id': 'ev-1',
        'attendance_id': 'att-1',
        'event_type': 'edit',
        'source': 'manual',
        'occurred_at': '2026-11-12T10:00:00Z',
        'received_at': '2026-11-12T10:00:01Z',
        'actor_user_id': 'u-1',
        'idempotency_key': 'k-1',
        'old_values': {'status': 'late'},
        'new_values': {'status': 'present'},
        'reason': 'Corrected clock',
      });
      expect(audit.oldValues?['status'], 'late');
      expect(audit.newValues?['status'], 'present');
      expect(audit.reason, 'Corrected clock');

      final summary = StaffAttendanceSummaryResponse.fromJson({
        'date_from': '2026-11-01',
        'date_to': '2026-11-12',
        'total_records': 10,
        'present': 8,
        'late': 1,
        'absent': 1,
        'leave': 0,
        'short_leave_days': 1,
        'check_in_count': 9,
        'check_out_count': 8,
        'incomplete_checkouts': 1,
        'total_worked_minutes': 3000,
        'attendance_percentage': 90.0,
        'people_with_records': 2,
        'people': const [],
        'summary_basis': 'saved_records_only',
      });
      expect(summary.totalWorkedMinutes, 3000);
      expect(summary.attendancePercentage, 90.0);
    });
  });

  group('StaffAttendanceRepository Unified Endpoints', () {
    test('calls roster, bulk-mark, patch edit, audit, history, and summary', () async {
      final adapter = _RecordingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final repo = StaffAttendanceRepository(dio);

      adapter.handler = (opts) {
        if (opts.path == 'attendance/staff/roster' ||
            opts.path == 'attendance/staff' ||
            opts.path == 'attendance/staff/teacher/t-1/history' ||
            opts.path == 'attendance/staff/att-1/audit') {
          return <dynamic>[];
        }
        if (opts.path == 'attendance/staff/bulk-mark') {
          return {'date': '2026-11-12', 'saved_count': 1, 'results': []};
        }
        return {
          'id': 'att-1',
          'date': '2026-11-12',
          'status': 'present',
          'date_from': '2026-11-01',
          'date_to': '2026-11-12',
        };
      };

      await repo.getRoster(date: DateTime(2026, 11, 12));
      await repo.editAttendance(
        attendanceId: 'att-1',
        request: const StaffAttendanceEditRequest(
          status: 'absent',
          reason: 'Marked absent',
        ),
      );
      await repo.getAuditTrail('att-1');
      await repo.getPersonHistory(personType: 'teacher', personId: 't-1');
      await repo.getSummary(
        dateFrom: DateTime(2026, 11, 1),
        dateTo: DateTime(2026, 11, 12),
        personType: 'teacher',
        personId: 't-1',
      );

      expect(
        adapter.requests.map((r) => '${r.method} ${r.path}').toList(),
        [
          'GET attendance/staff/roster',
          'PATCH attendance/staff/att-1',
          'GET attendance/staff/att-1/audit',
          'GET attendance/staff/teacher/t-1/history',
          'GET attendance/staff/summary',
        ],
      );
      expect(
        adapter.requests.last.queryParameters['person_type'],
        'teacher',
      );
      expect(adapter.requests.last.queryParameters['person_id'], 't-1');
    });
  });

  group('Unified Staff Attendance Screens', () {
    testWidgets('MarkStaffAttendanceScreen shows Not marked and hides edits for principal on mobile', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: _unifiedOverrides(),
          child: const MaterialApp(
            home: MarkStaffAttendanceScreen(isPrincipalReadOnly: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Principal Read-Only View'), findsOneWidget);
      expect(find.text('Sara Ahmed'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(find.text('Imran Clerk'), findsOneWidget);
      expect(find.text('Not marked'), findsOneWidget);
      expect(find.text('Save Row'), findsNothing);
    });

    testWidgets('MarkStaffAttendanceScreen shows bulk & single controls for management on desktop', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: _unifiedOverrides(),
          child: const MaterialApp(
            home: MarkStaffAttendanceScreen(isPrincipalReadOnly: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bulk Check-In / Out Defaults'), findsOneWidget);
      expect(find.text('Update Row'), findsOneWidget);
      expect(find.text('Save Row'), findsOneWidget);
    });

    testWidgets('StaffAttendanceListScreen renders records & summary on mobile and desktop', (tester) async {
      for (final size in [const Size(390, 844), const Size(1280, 800)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          ProviderScope(
            overrides: _unifiedOverrides(),
            child: const MaterialApp(
              home: StaffAttendanceListScreen(isPrincipalReadOnly: false),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sara Ahmed'), findsWidgets);
        expect(find.text('Short Leave'), findsOneWidget);

        await tester.tap(find.text('Summary & Hours'));
        await tester.pumpAndSettle();

        expect(find.text('85.7%'), findsOneWidget);
        expect(find.text('90h'), findsOneWidget);
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
