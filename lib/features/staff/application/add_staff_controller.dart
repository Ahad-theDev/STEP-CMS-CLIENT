
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'staff_repository_provider.dart';
import '../data/models/staff_member.dart';
import '../data/models/staff_create_request.dart';

part 'add_staff_controller.g.dart';

@riverpod
class AddStaffController extends _$AddStaffController {
  @override
  FutureOr<void> build() {}

  Future<StaffMember?> createStaff(StaffCreateRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(staffRepositoryProvider);
    try {
      final staff = await repo.createStaff(request);
      state = const AsyncData(null);
      return staff;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}