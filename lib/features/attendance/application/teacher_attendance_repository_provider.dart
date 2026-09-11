import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/teacher_attendance_repository.dart';

part 'teacher_attendance_repository_provider.g.dart';

@riverpod
TeacherAttendanceRepository teacherAttendanceRepository(TeacherAttendanceRepositoryRef ref) {
  return TeacherAttendanceRepository(ref.read(dioProvider));
}