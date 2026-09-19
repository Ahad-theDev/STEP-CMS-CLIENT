import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/core/network/auth_interceptor.dart';
import 'package:cms/core/network/token_refresh_interceptor.dart';
import 'package:cms/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final storage = ref.read(secureStorageProvider);
  dio.interceptors.add(AuthInterceptor(storage));
  dio.interceptors.add(TokenRefreshInterceptor(dio: dio, storage: storage));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
});