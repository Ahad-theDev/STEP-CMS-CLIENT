import 'notification_item.dart';

class NotificationListResponse {
  final int total;
  final int page;
  final int limit;
  final List<NotificationItem> items;

  NotificationListResponse({
    required this.total,
    required this.page,
    required this.limit,
    required this.items,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) => NotificationListResponse(
        total: json['total'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        items: (json['items'] as List)
            .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}