import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'staff_repository_provider.dart';
import '../data/models/staff_member.dart';

part 'all_staff_list_controller.g.dart';

@riverpod
class AllStaffListController extends _$AllStaffListController {
  @override
  Future<List<StaffMember>> build() async {
    final repo = ref.read(staffRepositoryProvider);
    return repo.listStaff(page: 1, limit: 200);
  }
}