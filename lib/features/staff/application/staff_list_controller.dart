import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'staff_repository_provider.dart';
import '../data/models/staff_member.dart';

part 'staff_list_controller.g.dart';

const int staffPageSize = 20;

@riverpod
class StaffListController extends _$StaffListController {
  @override
  Future<List<StaffMember>> build({int page = 1}) async {
    final repo = ref.read(staffRepositoryProvider);
    return repo.listStaff(page: page, limit: staffPageSize);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}