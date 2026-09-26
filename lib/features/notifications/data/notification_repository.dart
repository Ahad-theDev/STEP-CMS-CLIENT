import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/notification_item.dart';
import 'models/notification_list_response.dart';

class NotificationRepository {
  final Dio dio;
  NotificationRepository(this.dio);

  /// Backend caps this at 100 regardless of what's requested.
  Future<List<NotificationItem>> getUnread({int limit = 100}) async {
    final response = await dio.get(
      ApiConstants.notificationsUnread,
      queryParameters: {'limit': limit},
    );
    return (response.data as List).map((e) => NotificationItem.fromJson(e)).toList();
  }

  Future<NotificationListResponse> list({int page = 1, int limit = 20, bool? isRead}) async {
    final response = await dio.get(
      ApiConstants.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (isRead != null) 'is_read': isRead,
      },
    );
    return NotificationListResponse.fromJson(response.data);
  }

  Future<NotificationItem> markRead(String id) async {
    final response = await dio.patch(ApiConstants.notificationRead(id));
    return NotificationItem.fromJson(response.data);
  }

  Future<int> markAllRead() async {
    final response = await dio.patch(ApiConstants.notificationsReadAll);
    return response.data['marked_read'] as int;
  }
}