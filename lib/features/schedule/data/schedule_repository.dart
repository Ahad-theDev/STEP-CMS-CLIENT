import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/features/students/data/models/bulk_import_result.dart';
import 'models/schedule_preview_response.dart';
import 'models/bulk_shift_request.dart';
import 'models/publish_result.dart';

class ScheduleRepository {
  final Dio dio;
  ScheduleRepository(this.dio);

  Future<SchedulePreviewResponse> getPreview(DateTime date) async {
    final response = await dio.get(
      ApiConstants.schedulePreview,
      queryParameters: {'date': date.toIso8601String().split('T').first},
    );
    return SchedulePreviewResponse.fromJson(response.data);
  }

  Future<BulkImportResult> bulkShift(BulkShiftRequest request) async {
    final response = await dio.post(ApiConstants.scheduleBulkShift, data: request.toJson());
    return BulkImportResult.fromJson(response.data);
  }

  Future<PublishResult> publish(DateTime date) async {
    final response = await dio.post(
      ApiConstants.schedulePublish,
      queryParameters: {'date': date.toIso8601String().split('T').first},
    );
    return PublishResult.fromJson(response.data);
  }
}