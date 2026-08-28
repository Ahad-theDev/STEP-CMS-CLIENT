import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'class_repository_provider.dart';
import '../data/models/school_class.dart';
import '../data/models/class_update_request.dart';

part 'update_class_controller.g.dart';

@riverpod
class UpdateClassController extends _$UpdateClassController {
  @override
  FutureOr<void> build() {}

  Future<SchoolClass?> updateClass(String classId, ClassUpdateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(classRepositoryProvider);
    try {
      final cls = await repo.updateClass(classId, request);
      state = const AsyncData(null);
      return cls;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}