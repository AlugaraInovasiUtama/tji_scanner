import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../errors/exceptions.dart';

class ConnectivityInterceptor extends Interceptor {
  final Connectivity _connectivity;

  ConnectivityInterceptor(this._connectivity);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const NetworkException('No internet connection'),
          type: DioExceptionType.connectionError,
        ),
        true,
      );
      return;
    }
    handler.next(options);
  }
}
