import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<User> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    await _secureStorage.saveBaseUrl(baseUrl);
    final user = await _remoteDataSource.login(
      baseUrl: baseUrl,
      username: username,
      password: password,
    );
    await _secureStorage.saveUserId(user.id);
    await _secureStorage.saveUserName(user.name);
    // Fetch warehouse role (non-critical; session cookie already set by login)
    final role = await _remoteDataSource.getUserRole(baseUrl: baseUrl);
    await _secureStorage.saveUserRole(role);
    return UserModel(
      id: user.id,
      name: user.name,
      login: user.login,
      sessionId: user.sessionId,
      role: role,
    );
  }

  @override
  Future<void> logout() async {
    final baseUrl = await _secureStorage.getBaseUrl();
    if (baseUrl != null) {
      await _remoteDataSource.logout(baseUrl: baseUrl);
    }
    await _secureStorage.clearAll();
  }

  @override
  Future<User?> getStoredUser() async {
    final userId = await _secureStorage.getUserId();
    final userName = await _secureStorage.getUserName();
    final sessionId = await _secureStorage.getSessionId();
    final role = await _secureStorage.getUserRole();

    if (userId == null || userName == null) return null;

    return UserModel.fromStorage(
      id: userId,
      name: userName,
      login: '',
      sessionId: sessionId,
      role: role,
    );
  }

  @override
  Future<bool> isLoggedIn() async {
    final sessionId = await _secureStorage.getSessionId();
    final userId = await _secureStorage.getUserId();
    return sessionId != null &&
        sessionId.isNotEmpty &&
        userId != null &&
        userId > 0;
  }
}
