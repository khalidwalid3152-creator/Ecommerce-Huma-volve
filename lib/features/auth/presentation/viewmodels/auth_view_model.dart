import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/errors/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/login.dart';
import '../../domain/use_cases/logout.dart';
import '../../domain/use_cases/register.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required this._login,
    required this._register,
    required this._logout,
    required this._repository,
  });

  final Login _login;
  final Register _register;
  final Logout _logout;
  final AuthRepository _repository;

  bool isLoading = false;
  String? errorMessage;

  AuthUser? get currentUser => _repository.currentUser;

  Future<bool> login({required String email, required String password}) {
    return _run(() => _login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() => _register(name: name, email: email, password: password));
  }

  void logout() {
    _logout();
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
