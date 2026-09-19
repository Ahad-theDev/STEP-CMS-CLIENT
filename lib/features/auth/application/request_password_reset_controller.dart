import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_repository_provider.dart';

part 'request_password_reset_controller.g.dart';

@riverpod
class RequestPasswordResetController extends _$RequestPasswordResetController {
  @override
  FutureOr<void> build() {}

  Future<String?> submit(String identifier) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    try {
      final message = await repo.requestPasswordReset(identifier);
      state = const AsyncData(null);
      return message;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}