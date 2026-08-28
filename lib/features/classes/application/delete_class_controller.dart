import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'class_repository_provider.dart';

part 'delete_class_controller.g.dart';

@riverpod
class DeleteClassController extends _$DeleteClassController {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteClass(String classId) async {
    state = const AsyncLoading();
    final repo = ref.read(classRepositoryProvider);
    try {
      await repo.deleteClass(classId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}