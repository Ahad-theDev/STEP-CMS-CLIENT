import 'package:cms/features/fees/data/models/fee_defaulters_response.dart';
import 'package:cms/features/fees/data/models/fee_reminder_response.dart';
import 'package:cms/features/fees/data/models/fee_summary_response.dart';
import 'package:cms/features/fees/data/models/payment_request.dart';
import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/fee_record.dart';
import 'models/fee_generate_request.dart';
import 'models/fee_generate_result.dart';

class FeeRecordRepository {
  final Dio dio;
  FeeRecordRepository(this.dio);

  Future<List<FeeRecord>> listFeeRecords({
    String? studentId,
    int? month,
    int? year,
    String? status,
  }) async {
    final response = await dio.get(
      ApiConstants.fees,
      queryParameters: {
        ...? (studentId != null ? {'student_id': studentId} : null),
        ...? (month != null ? {'month': month} : null),
        ...? (year != null ? {'year': year} : null),
        ...? (status != null ? {'status': status} : null),
      },
    );
    return (response.data as List).map((e) => FeeRecord.fromJson(e)).toList();
  }

  Future<FeeGenerateResult> generateBulk(BulkGenerateFeesRequest request) async {
    final response = await dio.post(ApiConstants.feesGenerateBulk, data: request.toJson());
    return FeeGenerateResult.fromJson(response.data);
  }

  Future<FeeGenerateResult> generateForStudent(
      String studentId, SingleGenerateFeeRequest request) async {
    final response =
        await dio.post(ApiConstants.feesGenerateStudent(studentId), data: request.toJson());
    return FeeGenerateResult.fromJson(response.data);
  }
  Future<FeeRecord> payFee(String feeId, PaymentRequest request) async {
  final response = await dio.patch(ApiConstants.feesPay(feeId), data: request.toJson());
  return FeeRecord.fromJson(response.data);
}

Future<FeeReminderResponse> getDueToday() async {
  final response = await dio.get(ApiConstants.feesReminderDueToday);
  return FeeReminderResponse.fromJson(response.data);
}

Future<FeeReminderResponse> getOverdue() async {
  final response = await dio.get(ApiConstants.feesReminderOverdue);
  return FeeReminderResponse.fromJson(response.data);
}

Future<FeeReminderResponse> getUpcoming(int days) async {
  final response =
      await dio.get(ApiConstants.feesReminderUpcoming, queryParameters: {'days': days});
  return FeeReminderResponse.fromJson(response.data);
}

Future<FeeDefaultersResponse> getDefaulters({String? classId, int? month, int? year}) async {
  final response = await dio.get(ApiConstants.feesDefaulters, queryParameters: {
    ...? (classId != null ? {'class_id': classId} : null),
    ...? (month != null ? {'month': month} : null),
    ...? (year != null ? {'year': year} : null),
  });
  return FeeDefaultersResponse.fromJson(response.data);
}

Future<FeeSummaryResponse> getSummary({
  String? classId,
  int? fromMonth,
  int? fromYear,
  int? toMonth,
  int? toYear,
  String? groupBy,
}) async {
  final response = await dio.get(ApiConstants.feesSummary, queryParameters: {
    ...? (classId != null ? {'class_id': classId} : null),
    ...? (fromMonth != null ? {'from_month': fromMonth} : null),
    ...? (fromYear != null ? {'from_year': fromYear} : null),
    ...? (toMonth != null ? {'to_month': toMonth} : null),
    ...? (toYear != null ? {'to_year': toYear} : null),
    ...? (groupBy != null ? {'group_by': groupBy} : null),
  });
  return FeeSummaryResponse.fromJson(response.data);
}
}