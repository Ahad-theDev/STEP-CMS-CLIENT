import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/calendar_entry.dart';
import 'models/calendar_entry_create_request.dart';
import 'models/calendar_create_result.dart';
import 'models/calendar_delete_result.dart';

class CalendarRepository {
  final Dio dio;
  CalendarRepository(this.dio);

  static String _fmt(DateTime d) => d.toIso8601String().split('T').first;

  Future<CalendarCreateResult> createEntries(CalendarEntryCreateRequest request) async {
    final response = await dio.post(ApiConstants.calendarHolidays, data: request.toJson());
    return CalendarCreateResult.fromJson(response.data);
  }

  Future<List<CalendarEntry>> listEntries(DateTime from, DateTime to) async {
    final response = await dio.get(
      ApiConstants.calendarHolidays,
      queryParameters: {'from': _fmt(from), 'to': _fmt(to)},
    );
    return (response.data as List).map((e) => CalendarEntry.fromJson(e)).toList();
  }

  Future<CalendarDeleteResult> deleteEntries(DateTime dateFrom, DateTime? dateTo) async {
    final response = await dio.delete(
      ApiConstants.calendarHolidays,
      queryParameters: {
        'date_from': _fmt(dateFrom),
        if (dateTo != null) 'date_to': _fmt(dateTo),
      },
    );
    return CalendarDeleteResult.fromJson(response.data);
  }
}