import 'package:cms/core/utils/natural_order.dart';
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
    final items = await repo.listAllClasses();
    return [...items]..sort(
      (a, b) => naturalCompare(a.name, b.name) != 0
          ? naturalCompare(a.name, b.name)
          : naturalCompare(a.section, b.section),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
