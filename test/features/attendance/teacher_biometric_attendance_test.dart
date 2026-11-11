import 'dart:convert';
import 'dart:typed_data';

import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:cms/features/attendance/data/models/teacher_attendance_models.dart';
import 'package:cms/features/attendance/data/teacher_biometric_attendance_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubHttpAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;
  final Map<String, dynamic> responsePayload;

  _StubHttpAdapter(this.responsePayload);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString(
      jsonEncode(responsePayload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  group('attendance_event_utils', () {
    test('generateEventUuid returns RFC 4122 v4 UUIDs', () {
      final uuid1 = generateEventUuid();
      final uuid2 = generateEventUuid();
      expect(uuid1, isNot(equals(uuid2)));
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(uuid1),
        isTrue,
      );
    });

    test('formatIsoWithLocalOffset includes numeric timezone offset', () {
      final formatted = formatIsoWithLocalOffset(DateTime(2026, 11, 11, 7, 50));
      expect(
        RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$')
            .hasMatch(formatted),
        isTrue,
      );
    });
  });

  group('AttendancePolicyDay validation', () {
    test('accepts standard school weekday policy', () {
      final policy = AttendancePolicyDay.defaultForDay(0);
      expect(policy.validate(), isNull);
    });

    test('rejects end_time on or before start_time', () {
      final invalid = AttendancePolicyDay.defaultForDay(0).copyWith(
        startTime: '08:00:00',
        endTime: '08:00:00',
      );
      expect(invalid.validate(), contains('End time must be after start time'));
    });

    test('rejects check_in_cutoff earlier than start + late_grace', () {
      final invalid = AttendancePolicyDay.defaultForDay(1).copyWith(
        startTime: '08:00:00',
        endTime: '14:00:00',
        checkInCutoff: '08:05:00',
        lateGraceMinutes: 15,
      );
      expect(invalid.validate(), contains('late grace'));
    });

    test('rejects late_grace exceeding 240 minutes', () {
      final invalid = AttendancePolicyDay.defaultForDay(2).copyWith(
        lateGraceMinutes: 300,
      );
      expect(invalid.validate(), contains('between 0 and 240'));
    });
  });

  group('Teacher attendance models and repository', () {
    test('parses TeacherDailyAttendanceItem with check-in/out and sources', () {
      final item = TeacherDailyAttendanceItem.fromJson({
        'attendance_id': 'att-1',
        'teacher_id': 't-1',
        'teacher_name': 'Ms. Ayesha',
        'date': '2026-11-11',
        'status': 'late',
        'check_in_at': '2026-11-11T03:05:00+00:00',
        'check_out_at': '2026-11-11T08:15:00+00:00',
        'short_leave': true,
        'check_in_source': 'fingerprint',
        'check_out_source': 'manual',
      });
      expect(item.teacherName, 'Ms. Ayesha');
      expect(item.status, 'late');
      expect(item.shortLeave, isTrue);
      expect(item.checkInSource, 'fingerprint');
      expect(item.checkOutSource, 'manual');
      expect(item.checkInAt, isNotNull);
      expect(item.checkOutAt, isNotNull);
    });

    test('parses TeacherAttendanceSummary counts cleanly', () {
      final summary = TeacherAttendanceSummary.fromJson({
        'date_from': '2026-11-01',
        'date_to': '2026-11-11',
        'total_records': 20,
        'present': 14,
        'late': 3,
        'absent': 2,
        'leave': 1,
        'short_leave': 2,
      });
      expect(summary.totalRecords, 20);
      expect(summary.shortLeave, 2);
      expect(summary.present, 14);
    });

    test('submitFingerprintScan sends X-Attendance-Device-Token header', () async {
      final adapter = _StubHttpAdapter({
        'success': true,
        'duplicate': true,
        'teacher_id': 't-1',
        'teacher_name': 'Ali Khan',
        'event_type': 'check_in',
        'attendance_status': 'present',
        'attendance_date': '2026-11-11',
        'check_in_at': '2026-11-11T02:45:00Z',
        'check_out_at': null,
        'short_leave': false,
        'message': 'This scan was already processed.',
      });
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/'))
        ..httpClientAdapter = adapter;
      final repo = TeacherBiometricAttendanceRepository(dio);

      final resp = await repo.submitFingerprintScan(
        deviceToken: 'secret-device-token',
        request: const TeacherScanRequest(
          eventId: 'evt-00000000-0000-4000-8000-000000000001',
          teacherId: 't-1',
          deviceId: 'dev-1',
          eventType: 'check_in',
          capturedAt: '2026-11-11T07:45:00+05:00',
        ),
      );

      expect(
        adapter.lastOptions?.headers['X-Attendance-Device-Token'],
        'secret-device-token',
      );
      expect(resp.duplicate, isTrue);
      expect(resp.teacherName, 'Ali Khan');
      expect(resp.attendanceStatus, 'present');
    });
  });
}
