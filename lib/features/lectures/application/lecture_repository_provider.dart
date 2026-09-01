import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/lecture_repository.dart';

part 'lecture_repository_provider.g.dart';

@riverpod
LectureRepository lectureRepository(LectureRepositoryRef ref) {
  return LectureRepository(ref.read(dioProvider));
}