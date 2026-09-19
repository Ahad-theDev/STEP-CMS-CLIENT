import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/features/auth/data/models/auth_user.dart';
import 'package:cms/features/auth/data/models/register_request.dart';
import 'package:cms/features/auth/data/models/register_response.dart';
import 'package:cms/features/auth/data/models/token_response.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  Future<TokenResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await dio.post(
      ApiConstants.login,
      data: {"username": username, "password": password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return TokenResponse.fromJson(response.data);
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    return RegisterResponse.fromJson(response.data);
  }

  Future<AuthUser> getCurrentUser() async {
    final response = await dio.get(ApiConstants.me);
    return AuthUser.fromJson(response.data);
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await dio.post(
      ApiConstants.refresh,
      queryParameters: {'refresh_token': refreshToken},
    );
    final accessTokenData = response.data['access_token'];
    // Handle case where backend returns [token, jti] array
    if (accessTokenData is List && accessTokenData.isNotEmpty) {
      return accessTokenData[0] as String;
    }
    return accessTokenData as String;
  }
  Future<String> requestPasswordReset(String identifier) async {
  final response = await dio.post(
    ApiConstants.requestPasswordReset,
    queryParameters: {'identifier': identifier},
  );
  return response.data['message'] as String;
}

Future<String> resetPassword({required String token, required String newPassword}) async {
  final response = await dio.post(
    ApiConstants.resetPassword,
    queryParameters: {'token': token, 'new_password': newPassword},
  );
  return response.data['message'] as String;
}
}
