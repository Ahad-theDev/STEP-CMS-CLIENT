import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_record_repository_provider.dart';
import '../data/models/fee_record.dart';

part 'fee_records_list_controller.g.dart';

@riverpod
class FeeRecordsListController extends _$FeeRecordsListController {
  @override
  Future<List<FeeRecord>> build({String? studentId, int? month, int? year, String? status}) async {
    final repo = ref.read(feeRecordRepositoryProvider);
    return repo.listFeeRecords(studentId: studentId, month: month, year: year, status: status);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}