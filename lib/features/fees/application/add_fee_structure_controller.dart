import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_structure_repository_provider.dart';
import '../data/models/fee_structure.dart';
import '../data/models/fee_structure_create_request.dart';

part 'add_fee_structure_controller.g.dart';

@riverpod
class AddFeeStructureController extends _$AddFeeStructureController {
  @override
  FutureOr<void> build() {}

  Future<FeeStructure?> createFeeStructure(FeeStructureCreateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(feeStructureRepositoryProvider);
    try {
      final result = await repo.createFeeStructure(request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}