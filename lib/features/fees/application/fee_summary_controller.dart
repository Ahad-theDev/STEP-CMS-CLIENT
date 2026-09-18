import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_record_repository_provider.dart';
import '../data/models/fee_summary_response.dart';

part 'fee_summary_controller.g.dart';

@riverpod
class FeeSummaryController extends _$FeeSummaryController {
  @override
  Future<FeeSummaryResponse> build({
    String? classId,
    int? fromMonth,
    int? fromYear,
    int? toMonth,
    int? toYear,
  }) async {
    final repo = ref.read(feeRecordRepositoryProvider);
    return repo.getSummary(
      classId: classId,
      fromMonth: fromMonth,
      fromYear: fromYear,
      toMonth: toMonth,
      toYear: toYear,
      groupBy: 'class',
    );
  }
}