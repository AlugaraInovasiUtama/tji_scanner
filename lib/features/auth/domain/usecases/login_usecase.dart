import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User> call({
    required String baseUrl,
    required String db,
    required String username,
    required String password,
  }) {
    return _repository.login(
      baseUrl: baseUrl,
      db: db,
      username: username,
      password: password,
    );
  }
}
