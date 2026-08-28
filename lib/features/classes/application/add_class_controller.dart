import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'class_repository_provider.dart';
import '../data/models/school_class.dart';
import '../data/models/class_create_request.dart';

part 'add_class_controller.g.dart';

@riverpod
class AddClassController extends _$AddClassController {
  @override
  FutureOr<void> build() {}

  Future<SchoolClass?> createClass(ClassCreateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(classRepositoryProvider);
    try {
      final cls = await repo.createClass(request);
      state = const AsyncData(null);
      return cls;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}