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
        if (studentId != null) 'student_id': studentId,
        if (month != null) 'month': month,
        if (year != null) 'year': year,
        if (status != null) 'status': status,
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
}