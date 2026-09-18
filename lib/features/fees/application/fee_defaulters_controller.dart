import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_record_repository_provider.dart';
import '../data/models/fee_defaulters_response.dart';

part 'fee_defaulters_controller.g.dart';

@riverpod
class FeeDefaultersController extends _$FeeDefaultersController {
  @override
  Future<FeeDefaultersResponse> build({String? classId, int? month, int? year}) async {
    final repo = ref.read(feeRecordRepositoryProvider);
    return repo.getDefaulters(classId: classId, month: month, year: year);
  }
}