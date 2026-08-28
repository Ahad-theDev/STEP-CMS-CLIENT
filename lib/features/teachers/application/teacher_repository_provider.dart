import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../data/teacher_repository.dart';

part 'teacher_repository_provider.g.dart';

@riverpod
TeacherRepository teacherRepository(TeacherRepositoryRef ref) {
  return TeacherRepository(ref.read(dioProvider));
}