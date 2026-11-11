import 'package:cms/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/teacher_attendance_models.dart';
import '../data/teacher_biometric_attendance_repository.dart';
import '../services/biometric_scanner_service.dart';

final teacherBiometricAttendanceRepositoryProvider =
    Provider<TeacherBiometricAttendanceRepository>((ref) {
      return TeacherBiometricAttendanceRepository(ref.watch(dioProvider));
    });

final biometricScannerAdapterProvider = Provider<BiometricScannerAdapter>((ref) {
  return LocalWorkstationScannerAdapter(ref.watch(secureStorageProvider));
});

final attendanceDevicesProvider =
    FutureProvider.autoDispose<List<AttendanceDevice>>((ref) async {
      return ref
          .watch(teacherBiometricAttendanceRepositoryProvider)
          .listDevices();
    });

final attendancePolicyProvider =
    FutureProvider.autoDispose<List<AttendancePolicyDay>>((ref) async {
      return ref.watch(teacherBiometricAttendanceRepositoryProvider).getPolicy();
    });

final teacherEnrollmentsProvider = FutureProvider.autoDispose
    .family<List<FingerprintEnrollment>, String>((ref, teacherId) async {
      return ref
          .watch(teacherBiometricAttendanceRepositoryProvider)
          .listTeacherEnrollments(teacherId);
    });

final teacherDailyAttendanceProvider = FutureProvider.autoDispose
    .family<List<TeacherDailyAttendanceItem>, String>((ref, dateIso) async {
      final parsed = DateTime.parse(dateIso);
      return ref
          .watch(teacherBiometricAttendanceRepositoryProvider)
          .getDailyAttendance(date: parsed);
    });

class TeacherSummaryRange {
  final String dateFromIso;
  final String dateToIso;

  const TeacherSummaryRange({
    required this.dateFromIso,
    required this.dateToIso,
  });

  @override
  bool operator ==(Object other) =>
      other is TeacherSummaryRange &&
      other.dateFromIso == dateFromIso &&
      other.dateToIso == dateToIso;

  @override
  int get hashCode => Object.hash(dateFromIso, dateToIso);
}

final teacherAttendanceSummaryProvider = FutureProvider.autoDispose
    .family<TeacherAttendanceSummary, TeacherSummaryRange>((ref, range) async {
      return ref
          .watch(teacherBiometricAttendanceRepositoryProvider)
          .getSummary(
            dateFrom: DateTime.parse(range.dateFromIso),
            dateTo: DateTime.parse(range.dateToIso),
          );
    });
