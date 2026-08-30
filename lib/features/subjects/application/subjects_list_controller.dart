import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'subject_repository_provider.dart';
import '../data/models/subject.dart';

part 'subjects_list_controller.g.dart';

@riverpod
class SubjectsListController extends _$SubjectsListController {
  @override
  Future<List<Subject>> build() async {
    final repo = ref.read(subjectRepositoryProvider);
    return repo.listSubjects();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}