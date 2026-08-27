import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'staff_repository_provider.dart';
import '../data/models/staff_member.dart';
import '../data/models/staff_update_request.dart';

part 'update_staff_controller.g.dart';

@riverpod
class UpdateStaffController extends _$UpdateStaffController {
  @override
  FutureOr<void> build() {}

  Future<StaffMember?> updateStaff(String staffId, StaffUpdateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(staffRepositoryProvider);
    try {
      final staff = await repo.updateStaff(staffId, request);
      state = const AsyncData(null);
      return staff;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}