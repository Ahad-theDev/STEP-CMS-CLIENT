import 'package:cms/core/exceptions/api_exception.dart';
import 'package:cms/core/network/dio_client.dart';
import 'package:cms/features/auth/application/auth_repository_provider.dart';
import 'package:cms/features/auth/data/models/register_request.dart';
import 'package:cms/features/auth/data/models/register_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // idle initial state
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(secureStorageProvider);
    try {
      final tokens = await repo.login(username: username, password: password);
      await storage.saveToken(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      // Reset to data first to ensure rebuild on repeated errors
      state = const AsyncData(null);
      final apiException = mapDioExceptionToApiException(e);
      state = AsyncError(apiException, st);
      return false;
    }
  }

  Future<RegisterResponse?> register(RegisterRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    try {
      final result = await repo.register(request);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      // Reset to data first to ensure rebuild on repeated errors
      state = const AsyncData(null);
      final apiException = mapDioExceptionToApiException(e);
      state = AsyncError(apiException, st);
      return null;
    }
  }
}
