import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/network/dio_client.dart';
import 'package:cms/features/exams/data/exam_repository.dart';

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ExamRepository(dio);
});
