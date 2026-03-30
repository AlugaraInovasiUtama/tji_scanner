import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/interceptors/auth_interceptor.dart';
import '../../core/network/interceptors/connectivity_interceptor.dart';
import '../../core/network/network_info.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/scanner/data/scan_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SecureStorage());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => NetworkInfo(sl<Connectivity>()));

  // ── Network ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => AuthInterceptor(sl<SecureStorage>()));
  sl.registerLazySingleton(() => ConnectivityInterceptor(sl<Connectivity>()));

  sl.registerLazySingleton<Dio>(() => DioClient.getInstance(
    baseUrl: ApiConstants.defaultBaseUrl,
    authInterceptor: sl<AuthInterceptor>(),
    connectivityInterceptor: sl<ConnectivityInterceptor>(),
  ));

  // ── Auth ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<SecureStorage>()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl<LoginUseCase>(),
    logoutUseCase: sl<LogoutUseCase>(),
    authRepository: sl<AuthRepository>(),
  ));

  // ── Scan ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ScanService(sl<Dio>()));
}
