import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_record_repository_provider.dart';
import '../data/models/fee_generate_request.dart';
import '../data/models/fee_generate_result.dart';

part 'generate_student_fee_controller.g.dart';

@riverpod
class GenerateStudentFeeController extends _$GenerateStudentFeeController {
  @override
  FutureOr<void> build() {}

  Future<FeeGenerateResult?> generate(String studentId, SingleGenerateFeeRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(feeRecordRepositoryProvider);
    try {
      final result = await repo.generateForStudent(studentId, request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}