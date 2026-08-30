import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'subject_repository_provider.dart';

part 'delete_subject_controller.g.dart';

@riverpod
class DeleteSubjectController extends _$DeleteSubjectController {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteSubject(String subjectId) async {
    state = const AsyncLoading();
    final repo = ref.read(subjectRepositoryProvider);
    try {
      await repo.deleteSubject(subjectId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}