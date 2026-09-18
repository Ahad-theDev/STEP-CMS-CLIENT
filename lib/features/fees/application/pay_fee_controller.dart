import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fee_record_repository_provider.dart';
import '../data/models/fee_record.dart';
import '../data/models/payment_request.dart';

part 'pay_fee_controller.g.dart';

@riverpod
class PayFeeController extends _$PayFeeController {
  @override
  FutureOr<void> build() {}

  Future<FeeRecord?> pay(String feeId, PaymentRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(feeRecordRepositoryProvider);
    try {
      final result = await repo.payFee(feeId, request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}