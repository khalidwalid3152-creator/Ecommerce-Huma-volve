import 'package:dio/dio.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/errors/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  String? _accessToken;
  AuthUser? _currentUser;

  @override
  String? get accessToken => _accessToken;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      _accessToken = result.accessToken;
      _currentUser = result.user;
      return result.user;
    } on DioException catch (error) {
      throw AuthException(_messageFrom(error));
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
    } on DioException catch (error) {
      throw AuthException(_messageFrom(error));
    }
  }

  @override
  void logout() {
    _accessToken = null;
    _currentUser = null;
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      if (message is List && message.isNotEmpty) return message.join('\n');
    }
    if (error.response == null) {
      return 'Unable to connect. Check your internet connection and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
