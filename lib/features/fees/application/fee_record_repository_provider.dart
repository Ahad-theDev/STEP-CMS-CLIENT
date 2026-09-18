import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/fee_record_repository.dart';

part 'fee_record_repository_provider.g.dart';

@riverpod
FeeRecordRepository feeRecordRepository(FeeRecordRepositoryRef ref) {
  return FeeRecordRepository(ref.read(dioProvider));
}