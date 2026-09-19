import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_repository_provider.dart';

part 'reset_password_controller.g.dart';

@riverpod
class ResetPasswordController extends _$ResetPasswordController {
  @override
  FutureOr<void> build() {}

  Future<String?> submit({required String token, required String newPassword}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    try {
      final message = await repo.resetPassword(token: token, newPassword: newPassword);
      state = const AsyncData(null);
      return message;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}