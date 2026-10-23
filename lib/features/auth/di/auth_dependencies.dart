import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/use_cases/login.dart';
import '../domain/use_cases/logout.dart';
import '../domain/use_cases/register.dart';
import '../presentation/viewmodels/auth_view_model.dart';

final AuthRepository authRepository = AuthRepositoryImpl(
  AuthRemoteDataSource(),
);

AuthViewModel createAuthViewModel() {
  return AuthViewModel(
    login: Login(authRepository),
    register: Register(authRepository),
    logout: Logout(authRepository),
    repository: authRepository,
  );
}
