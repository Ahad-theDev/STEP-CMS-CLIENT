import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/student_repository.dart';

part 'student_repository_provider.g.dart';

@riverpod
StudentRepository studentRepository(StudentRepositoryRef ref) {
  return StudentRepository(ref.read(dioProvider));
}