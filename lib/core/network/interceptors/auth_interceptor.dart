import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final sessionId = await _secureStorage.getSessionId();
    if (sessionId != null && sessionId.isNotEmpty) {
      options.headers['Cookie'] = 'session_id=$sessionId';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Extract session_id from response headers if present
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      for (final cookie in setCookie) {
        if (cookie.contains('session_id=')) {
          final sessionId = _extractSessionId(cookie);
          if (sessionId != null) {
            _secureStorage.saveSessionId(sessionId);
          }
        }
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _secureStorage.clearAll();
    }
    handler.next(err);
  }

  String? _extractSessionId(String cookieHeader) {
    final match = RegExp(r'session_id=([^;]+)').firstMatch(cookieHeader);
    return match?.group(1);
  }
}
