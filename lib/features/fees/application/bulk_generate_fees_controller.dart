import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_record_repository_provider.dart';
import '../data/models/fee_generate_request.dart';
import '../data/models/fee_generate_result.dart';

part 'bulk_generate_fees_controller.g.dart';

@riverpod
class BulkGenerateFeesController extends _$BulkGenerateFeesController {
  @override
  FutureOr<void> build() {}

  Future<FeeGenerateResult?> generate(BulkGenerateFeesRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(feeRecordRepositoryProvider);
    try {
      final result = await repo.generateBulk(request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}