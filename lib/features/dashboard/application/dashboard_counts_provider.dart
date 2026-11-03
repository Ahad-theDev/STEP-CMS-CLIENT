import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/network/dio_client.dart';

final dashboardCountsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final response = await ref.watch(dioProvider).get('/dashboard/counts');
  return (response.data as Map).map(
    (key, value) => MapEntry(key as String, (value as num).toInt()),
  );
});
