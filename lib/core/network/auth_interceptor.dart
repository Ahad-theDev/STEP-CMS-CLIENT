import 'package:cms/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService storage;
  AuthInterceptor(this.storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthEndpoint = options.path.contains('/auth/login') ||
        options.path.contains('/auth/refresh') ||
        options.path.contains('/auth/request-password-reset') ||
        options.path.contains('/auth/reset-password') ||
        options.path.contains('/auth/register');

    if (!isAuthEndpoint) {
      final token = await storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } else {
      handler.next(options);
    }
  }
}
