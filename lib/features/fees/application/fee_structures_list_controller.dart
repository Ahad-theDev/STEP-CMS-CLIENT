import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_structure_repository_provider.dart';
import '../data/models/fee_structure.dart';

part 'fee_structures_list_controller.g.dart';

@riverpod
class FeeStructuresListController extends _$FeeStructuresListController {
  @override
  Future<List<FeeStructure>> build({String? classId, String? academicYear}) async {
    final repo = ref.read(feeStructureRepositoryProvider);
    return repo.listFeeStructures(classId: classId, academicYear: academicYear);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}