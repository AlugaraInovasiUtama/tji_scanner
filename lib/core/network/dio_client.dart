import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';

class DioClient {
  static Dio? _dio;
  static String? _currentBaseUrl;

  static Dio getInstance({
    required String baseUrl,
    required AuthInterceptor authInterceptor,
    required ConnectivityInterceptor connectivityInterceptor,
  }) {
    if (_dio == null || _currentBaseUrl != baseUrl) {
      _dio = _createDio(
        baseUrl: baseUrl,
        authInterceptor: authInterceptor,
        connectivityInterceptor: connectivityInterceptor,
      );
      _currentBaseUrl = baseUrl;
    }
    return _dio!;
  }

  static Dio _createDio({
    required String baseUrl,
    required AuthInterceptor authInterceptor,
    required ConnectivityInterceptor connectivityInterceptor,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: ApiConstants.contentType,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      connectivityInterceptor,
      authInterceptor,
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    ]);

    return dio;
  }

  static void reset() {
    _dio = null;
    _currentBaseUrl = null;
  }

  /// Update the baseUrl of the existing Dio instance in-place.
  /// Called after login when the user switches server URLs.
  static void updateBaseUrl(String baseUrl) {
    _currentBaseUrl = baseUrl;
    _dio?.options.baseUrl = baseUrl;
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print('[TJI-API] $message');
}
