import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'class_repository_provider.dart';
import '../data/models/school_class.dart';

part 'classes_list_controller.g.dart';

@riverpod
class ClassesListController extends _$ClassesListController {
  @override
  Future<List<SchoolClass>> build() async {
    final repo = ref.read(classRepositoryProvider);
    return repo.listClasses();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}