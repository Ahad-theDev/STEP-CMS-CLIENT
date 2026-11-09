import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/network/dio_client.dart';
import 'package:cms/features/reports/data/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportsRepository(dio);
});
