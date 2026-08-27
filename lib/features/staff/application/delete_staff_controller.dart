import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'staff_repository_provider.dart';

part 'delete_staff_controller.g.dart';

@riverpod
class DeleteStaffController extends _$DeleteStaffController {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteStaff(String staffId) async {
    state = const AsyncLoading();
    final repo = ref.read(staffRepositoryProvider);
    try {
      await repo.deleteStaff(staffId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}