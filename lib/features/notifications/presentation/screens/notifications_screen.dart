import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/notifications_list_controller.dart';
import '../../application/mark_notification_read_controller.dart';
import '../../application/mark_all_notifications_read_controller.dart';
import '../../application/unread_notifications_controller.dart';
import '../../data/models/notification_item.dart';

enum _NotificationsFilter { all, unread }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _NotificationsFilter _filter = _NotificationsFilter.all;
  int _page = 1;

  bool? get _isReadParam => _filter == _NotificationsFilter.unread ? false : null;

  Future<void> _refresh() async {
    await ref
        .read(notificationsListControllerProvider(isRead: _isReadParam, page: _page).notifier)
        .refresh();
    ref.invalidate(unreadNotificationsControllerProvider);
  }

  Future<void> _markRead(NotificationItem item) async {
    if (item.isRead) return;
    final result = await ref.read(markNotificationReadControllerProvider.notifier).markRead(item.id);
    if (!mounted) return;
    if (result == null) {
      final error = ref.read(markNotificationReadControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed: ${error != null ? friendlyErrorMessage(error) : 'Unknown error'}'),
      ));
      return;
    }
    ref.invalidate(notificationsListControllerProvider(isRead: _isReadParam, page: _page));
    ref.invalidate(unreadNotificationsControllerProvider);
  }

  Future<void> _markAllRead() async {
    final count = await ref.read(markAllNotificationsReadControllerProvider.notifier).markAllRead();
    if (!mounted) return;
    if (count == null) {
      final error = ref.read(markAllNotificationsReadControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed: ${error != null ? friendlyErrorMessage(error) : 'Unknown error'}'),
      ));
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Marked $count notification(s) as read')));
    ref.invalidate(notificationsListControllerProvider(isRead: _isReadParam, page: _page));
    ref.invalidate(unreadNotificationsControllerProvider);
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'daily_schedule':
        return Icons.calendar_today_rounded;
      case 'attendance_pending_reminder':
        return Icons.assignment_late_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Widget _buildMessage(BuildContext context, NotificationItem item) {
    final lines = item.message.split('\n');
    final header = lines.isNotEmpty ? lines.first : item.message;
    final bulletLines = lines.length > 1 ? lines.sublist(1) : <String>[];

    Color lineColor(String line) {
      final lower = line.toLowerCase();
      if (lower.contains('cancelled')) return Colors.red;
      if (lower.contains('substituting')) return Colors.orange;
      if (lower.contains('rescheduled')) return Colors.blue;
      return Theme.of(context).colorScheme.onSurface;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(header,
            style: TextStyle(fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold)),
        if (bulletLines.isNotEmpty) const SizedBox(height: 4),
        ...bulletLines.map((line) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                line.replaceFirst(RegExp(r'^-\s*'), '• '),
                style: TextStyle(fontSize: 13, color: lineColor(line)),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync =
        ref.watch(notificationsListControllerProvider(isRead: _isReadParam, page: _page));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllRead,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<_NotificationsFilter>(
              segments: const [
                ButtonSegment(value: _NotificationsFilter.all, label: Text('All')),
                ButtonSegment(value: _NotificationsFilter.unread, label: Text('Unread')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() {
                _filter = s.first;
                _page = 1;
              }),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load: ${friendlyErrorMessage(e)}')),
                data: (response) {
                  if (response.items.isEmpty) {
                    return ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: Center(child: Text('No notifications')),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    itemCount: response.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = response.items[index];
                      return ListTile(
                        leading: Icon(
                          _iconForType(item.type),
                          color: item.isRead ? Colors.grey : Theme.of(context).colorScheme.primary,
                        ),
                        title: _buildMessage(context, item),
                        subtitle: Text(_fmt(item.createdAt)),
                        trailing: item.isRead
                            ? null
                            : Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                        onTap: () => _markRead(item),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          if ((notificationsAsync.valueOrNull?.total ?? 0) > notificationsPageSize)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _page > 1 ? () => setState(() => _page -= 1) : null,
                  ),
                  Text('Page $_page'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: (notificationsAsync.valueOrNull != null &&
                            _page * notificationsPageSize < notificationsAsync.valueOrNull!.total)
                        ? () => setState(() => _page += 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}