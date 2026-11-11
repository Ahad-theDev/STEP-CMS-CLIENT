import 'dart:developer' as dev;
import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/core/network/auth_interceptor.dart';
import 'package:cms/core/network/token_refresh_interceptor.dart';
import 'package:cms/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

String _redactSensitiveLogLine(String line) {
  var sanitized = line.replaceAllMapped(
    RegExp(r'(Bearer\s+)[A-Za-z0-9._\-]+', caseSensitive: false),
    (m) => '${m.group(1)}[REDACTED]',
  );
  sanitized = sanitized.replaceAllMapped(
    RegExp(r'(X-Attendance-Device-Token\s*:\s*)\S+', caseSensitive: false),
    (m) => '${m.group(1)}[REDACTED]',
  );
  sanitized = sanitized.replaceAllMapped(
    RegExp(r'("device_token"\s*:\s*)"[^"]*"', caseSensitive: false),
    (m) => '${m.group(1)}"[REDACTED]"',
  );
  return sanitized;
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final storage = ref.read(secureStorageProvider);
  dio.interceptors.add(AuthInterceptor(storage));
  dio.interceptors.add(TokenRefreshInterceptor(dio: dio, storage: storage));
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => dev.log(_redactSensitiveLogLine(obj.toString()), name: 'DIO'),
    ),
  );
  return dio;
});