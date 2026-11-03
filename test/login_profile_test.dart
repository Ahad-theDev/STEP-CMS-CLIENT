import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:cms/features/auth/data/auth_repository.dart';
import 'package:cms/features/auth/application/auth_controller.dart';
import 'package:cms/features/auth/application/auth_repository_provider.dart';
import 'package:cms/core/network/dio_client.dart';
import 'package:cms/core/storage/secure_storage_service.dart';

class MemoryStorage extends SecureStorageService {
  bool saved = false;
  @override
  Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    saved = true;
  }
}

void main() {
  for (final role in ['teacher', 'management']) {
    for (final embedded in [true, false]) {
      test('$role profile ready before success; embedded=$embedded', () async {
        final profile = {
          'id': 'user1',
          'username': 'test',
          'email': 'test@example.com',
          'full_name': 'Test User',
          'role': role,
          'is_active': true,
        };
        final requests = <String>[];
        final dio = Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                requests.add(options.path);
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: options.path == 'auth/login'
                        ? {
                            'access_token': 'access',
                            'refresh_token': 'refresh',
                            if (embedded) 'user': profile,
                          }
                        : profile,
                  ),
                );
              },
            ),
          );
        final storage = MemoryStorage();
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => AuthRepository(dio)),
            secureStorageProvider.overrideWithValue(storage),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(
          authControllerProvider,
          (_, _) {},
        );
        addTearDown(subscription.close);
        await container.read(authControllerProvider.future);
        final controller = container.read(authControllerProvider.notifier);
        expect(
          await controller.login(username: 'test', password: 'test'),
          isTrue,
        );
        expect(storage.saved, isTrue);
        expect(controller.signedInUser?.role, role);
        expect(requests, embedded ? ['auth/login'] : ['auth/login', 'auth/me']);
      });
    }
  }
}
