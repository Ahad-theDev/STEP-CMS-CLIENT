import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/features/auth/data/models/register_request.dart';
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

  Future<void> register(RegisterRequest request) async {
    await dio.post(ApiConstants.register, data: request.toJson());
  }
}
