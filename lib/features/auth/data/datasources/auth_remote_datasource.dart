import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String baseUrl,
    required String username,
    required String password,
  });

  Future<void> logout({required String baseUrl});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/web/session/authenticate',
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            // 'db': 'Algr_Tji_16_Ce',
            'db': 'tji_dev',
            'login': username,
            'password': password,
          },
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        throw AuthException(
          data['error']['data']['message'] ?? 'Login failed',
        );
      }

      return UserModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('Username atau password salah');
      }
      throw NetworkException(e.message ?? 'Network error');
    }
  }

  @override
  Future<void> logout({required String baseUrl}) async {
    try {
      await _dio.post(
        '$baseUrl/web/session/destroy',
        data: {'jsonrpc': '2.0', 'method': 'call', 'params': {}},
      );
    } catch (_) {
      // ignore logout errors
    }
  }
}
