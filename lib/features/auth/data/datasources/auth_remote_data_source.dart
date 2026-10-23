import 'package:dio/dio.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/errors/auth_exception.dart';
import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({Dio? dio})
    : _dio =
          dio ?? Dio(BaseOptions(baseUrl: 'https://api.escuelajs.co/api/v1'));

  final Dio _dio;

  Future<({String accessToken, AuthUser user})> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final token = response.data?['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const AuthException('The server did not return an access token.');
    }

    final profileResponse = await _dio.get<Map<String, dynamic>>(
      '/auth/profile',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final profile = profileResponse.data;
    if (profile == null) {
      throw const AuthException('Could not load your account profile.');
    }

    return (accessToken: token, user: AuthUserModel.fromJson(profile));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/users',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'customer',
        'avatar':
            'https://api.dicebear.com/9.x/initials/png?seed=${Uri.encodeComponent(name)}',
      },
    );
  }
}
