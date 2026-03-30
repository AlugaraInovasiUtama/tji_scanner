import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String baseUrl,
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<User?> getStoredUser();

  Future<bool> isLoggedIn();
}
