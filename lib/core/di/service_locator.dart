import 'package:chronoflow/core/network/network_client.dart';
import 'package:chronoflow/core/shared/contants.dart';
import 'package:chronoflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:chronoflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chronoflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:chronoflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:chronoflow/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  serviceLocator
    // Core
    ..registerFactory<Constant>(Constant.new)
    ..registerFactory<Dio>(
      () => NetworkClient(Dio(), constant: serviceLocator()).dio,
    )
    // Auth Feature
    // 1. Data Sources (factory - new instance each time, or singleton if you prefer)
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
    )
    // 2. Repository (singleton - same instance app-wide)
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )
    // 3. Use Cases (factory - lightweight, can recreate)
    ..registerFactory(() => LoginUseCase(serviceLocator()))
    ..registerFactory(() => LogoutUseCase(serviceLocator()))
    // 4. Bloc (factory - fresh instance for each screen)
    ..registerFactory(
      () => AuthBloc(
        loginUseCase: serviceLocator(),
        logoutUseCase: serviceLocator(),
      ),
    );
}
