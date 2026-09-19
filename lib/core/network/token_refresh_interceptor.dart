import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService storage;
  TokenRefreshInterceptor({required this.dio, required this.storage});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final isAuthCall = requestOptions.path.contains('/auth/login') ||
        requestOptions.path.contains('/auth/refresh');
    final alreadyRetried = requestOptions.extra['retriedAfterRefresh'] == true;

    if (err.response?.statusCode != 401 || isAuthCall || alreadyRetried) {
      return handler.next(err);
    }

    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null) {
      await storage.clearToken();
      return handler.next(err);
    }

    try {
      final refreshResponse = await dio.post(
        ApiConstants.refresh,
        queryParameters: {'refresh_token': refreshToken},
      );
      final accessTokenData = refreshResponse.data['access_token'];
      // Handle case where backend returns [token, jti] array
      final newAccessToken = accessTokenData is List && accessTokenData.isNotEmpty
          ? accessTokenData[0] as String
          : accessTokenData as String;

      // Backend doesn't rotate the refresh token on /auth/refresh — reuse the one we have.
      await storage.saveToken(accessToken: newAccessToken, refreshToken: refreshToken);

      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      requestOptions.extra['retriedAfterRefresh'] = true;

      final retryResponse = await dio.fetch(requestOptions);
      return handler.resolve(retryResponse);
    } catch (_) {
      // Refresh token itself is expired/revoked — nothing left to try.
      await storage.clearToken();
      return handler.next(err);
    }
  }
}