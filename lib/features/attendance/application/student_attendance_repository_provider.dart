import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/student_attendance_repository.dart';

part 'student_attendance_repository_provider.g.dart';

@riverpod
StudentAttendanceRepository studentAttendanceRepository(StudentAttendanceRepositoryRef ref) {
  return StudentAttendanceRepository(ref.read(dioProvider));
}