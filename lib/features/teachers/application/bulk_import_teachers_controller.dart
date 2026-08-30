import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'teacher_repository_provider.dart';
import 'package:cms/features/students/data/models/bulk_import_result.dart';

part 'bulk_import_teachers_controller.g.dart';

@riverpod
class BulkImportTeachersController extends _$BulkImportTeachersController {
  @override
  FutureOr<void> build() {}

  Future<BulkImportResult?> importFile(String filePath, String fileName) async {
    state = const AsyncLoading();
    final repo = ref.read(teacherRepositoryProvider);
    try {
      final result = await repo.bulkImportTeachers(filePath, fileName);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}
