import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'class_repository_provider.dart';
import '../data/models/school_class.dart';

part 'classes_list_controller.g.dart';

const int classPageSize = 10;

@riverpod
class ClassesListController extends _$ClassesListController {
  @override
  Future<List<SchoolClass>> build({int page = 1}) async {
    final repo = ref.read(classRepositoryProvider);
    return repo.listClasses(page: page, limit: classPageSize);
  }

  Future<void> refresh({int page = 1}) async {
    ref.invalidateSelf();
    await ref.read(classesListControllerProvider(page: page).future);
  }
}