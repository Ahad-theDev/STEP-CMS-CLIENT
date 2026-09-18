import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_structure_repository_provider.dart';
import '../data/models/fee_structure.dart';
import '../data/models/fee_structure_update_request.dart';

part 'update_fee_structure_controller.g.dart';

@riverpod
class UpdateFeeStructureController extends _$UpdateFeeStructureController {
  @override
  FutureOr<void> build() {}

  Future<FeeStructure?> updateFeeStructure(String id, FeeStructureUpdateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(feeStructureRepositoryProvider);
    try {
      final result = await repo.updateFeeStructure(id, request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}