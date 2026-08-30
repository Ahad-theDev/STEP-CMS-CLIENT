import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'subject_repository_provider.dart';
import '../data/models/subject.dart';
import '../data/models/subject_create_request.dart';

part 'add_subject_controller.g.dart';

@riverpod
class AddSubjectController extends _$AddSubjectController {
  @override
  FutureOr<void> build() {}

  Future<Subject?> createSubject(SubjectCreateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(subjectRepositoryProvider);
    try {
      final subject = await repo.createSubject(request);
      state = const AsyncData(null);
      return subject;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}