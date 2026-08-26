import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_repository_provider.dart';
import '../data/models/bulk_import_result.dart';

part 'bulk_import_students_controller.g.dart';

@riverpod
class BulkImportStudentsController extends _$BulkImportStudentsController {
  @override
  FutureOr<void> build() {}

  Future<BulkImportResult?> importFile(String filePath, String fileName) async {
    state = const AsyncLoading();
    final repo = ref.read(studentRepositoryProvider);
    try {
      final result = await repo.bulkImportStudents(filePath, fileName);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}