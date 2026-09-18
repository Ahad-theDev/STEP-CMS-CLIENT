import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/fee_structure_repository.dart';

part 'fee_structure_repository_provider.g.dart';

@riverpod
FeeStructureRepository feeStructureRepository(FeeStructureRepositoryRef ref) {
  return FeeStructureRepository(ref.read(dioProvider));
}