import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  String? get accessToken;

  AuthUser? get currentUser;

  Future<AuthUser> login({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  void logout();
}
