import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'subject_repository_provider.dart';
import '../data/models/subject.dart';
import '../data/models/subject_update_request.dart';

part 'update_subject_controller.g.dart';

@riverpod
class UpdateSubjectController extends _$UpdateSubjectController {
  @override
  FutureOr<void> build() {}

  Future<Subject?> updateSubject(String subjectId, SubjectUpdateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(subjectRepositoryProvider);
    try {
      final subject = await repo.updateSubject(subjectId, request);
      state = const AsyncData(null);
      return subject;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}