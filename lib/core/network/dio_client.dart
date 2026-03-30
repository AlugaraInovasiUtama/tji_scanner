import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';

class DioClient {
  static Dio? _dio;

  static Dio getInstance({
    required String baseUrl,
    required AuthInterceptor authInterceptor,
    required ConnectivityInterceptor connectivityInterceptor,
  }) {
    _dio ??= _createDio(
      baseUrl: baseUrl,
      authInterceptor: authInterceptor,
      connectivityInterceptor: connectivityInterceptor,
    );
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
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print('[TJI-API] $message');
}
