import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'class_repository_provider.dart';
import '../data/models/school_class.dart';

part 'all_classes_controller.g.dart';

@riverpod
class AllClassesController extends _$AllClassesController {
  @override
  Future<List<SchoolClass>> build() async {
    final repo = ref.read(classRepositoryProvider);
    return repo.listClasses(page: 1, limit: 500);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
