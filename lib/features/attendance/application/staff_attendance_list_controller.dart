import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/staff_attendance.dart';
import '../data/models/staff_attendance_unified_models.dart';
import 'staff_attendance_repository_provider.dart';

class StaffAttendanceListFilter {
  final String? dateIso;
  final String? dateFromIso;
  final String? dateToIso;
  final String? personType;
  final String? personId;
  final String? status;
  final bool? shortLeave;

  const StaffAttendanceListFilter({
    this.dateIso,
    this.dateFromIso,
    this.dateToIso,
    this.personType,
    this.personId,
    this.status,
    this.shortLeave,
  });

  @override
  bool operator ==(Object other) =>
      other is StaffAttendanceListFilter &&
      other.dateIso == dateIso &&
      other.dateFromIso == dateFromIso &&
      other.dateToIso == dateToIso &&
      other.personType == personType &&
      other.personId == personId &&
      other.status == status &&
      other.shortLeave == shortLeave;

  @override
  int get hashCode => Object.hash(
        dateIso,
        dateFromIso,
        dateToIso,
        personType,
        personId,
        status,
        shortLeave,
      );
}

class StaffAttendanceSummaryFilter {
  final String dateFromIso;
  final String dateToIso;
  final String? personType;
  final String? personId;

  const StaffAttendanceSummaryFilter({
    required this.dateFromIso,
    required this.dateToIso,
    this.personType,
    this.personId,
  });

  @override
  bool operator ==(Object other) =>
      other is StaffAttendanceSummaryFilter &&
      other.dateFromIso == dateFromIso &&
      other.dateToIso == dateToIso &&
      other.personType == personType &&
      other.personId == personId;

  @override
  int get hashCode =>
      Object.hash(dateFromIso, dateToIso, personType, personId);
}

class StaffPersonHistoryFilter {
  final String personType;
  final String personId;
  final String? dateFromIso;
  final String? dateToIso;

  const StaffPersonHistoryFilter({
    required this.personType,
    required this.personId,
    this.dateFromIso,
    this.dateToIso,
  });

  @override
  bool operator ==(Object other) =>
      other is StaffPersonHistoryFilter &&
      other.personType == personType &&
      other.personId == personId &&
      other.dateFromIso == dateFromIso &&
      other.dateToIso == dateToIso;

  @override
  int get hashCode =>
      Object.hash(personType, personId, dateFromIso, dateToIso);
}

final staffAttendanceRosterProvider = FutureProvider.autoDispose
    .family<List<StaffAttendanceRosterItem>, String>((ref, dateIso) async {
  return ref
      .watch(staffAttendanceRepositoryProvider)
      .getRoster(date: DateTime.parse(dateIso));
});

final staffAttendanceListProvider = FutureProvider.autoDispose
    .family<List<StaffAttendance>, StaffAttendanceListFilter>((ref, f) async {
  return ref.watch(staffAttendanceRepositoryProvider).listAttendance(
        date: f.dateIso != null ? DateTime.parse(f.dateIso!) : null,
        dateFrom:
            f.dateFromIso != null ? DateTime.parse(f.dateFromIso!) : null,
        dateTo: f.dateToIso != null ? DateTime.parse(f.dateToIso!) : null,
        personType: f.personType,
        personId: f.personId,
        status: f.status,
        shortLeave: f.shortLeave,
      );
});

final staffAttendanceSummaryProvider = FutureProvider.autoDispose
    .family<StaffAttendanceSummaryResponse, StaffAttendanceSummaryFilter>(
        (ref, f) async {
  return ref.watch(staffAttendanceRepositoryProvider).getSummary(
        dateFrom: DateTime.parse(f.dateFromIso),
        dateTo: DateTime.parse(f.dateToIso),
        personType: f.personType,
        personId: f.personId,
      );
});

final staffPersonHistoryProvider = FutureProvider.autoDispose
    .family<List<StaffAttendance>, StaffPersonHistoryFilter>((ref, f) async {
  return ref.watch(staffAttendanceRepositoryProvider).getPersonHistory(
        personType: f.personType,
        personId: f.personId,
        dateFrom:
            f.dateFromIso != null ? DateTime.parse(f.dateFromIso!) : null,
        dateTo: f.dateToIso != null ? DateTime.parse(f.dateToIso!) : null,
      );
});

final staffAttendanceAuditProvider = FutureProvider.autoDispose
    .family<List<StaffAttendanceAuditItem>, String>((ref, attendanceId) async {
  return ref
      .watch(staffAttendanceRepositoryProvider)
      .getAuditTrail(attendanceId);
});