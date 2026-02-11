import 'package:chronoflow/core/errors/exceptions.dart';
import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:chronoflow/features/auth/data/models/login_request_model.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';
import 'package:chronoflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  Future<Either<Failure, T>> _handleExceptions<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on Object catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> login({
    required String username,
    required String password,
    required bool remember,
  }) async {
    return _handleExceptions(() async {
      final request = LoginRequestModel(
        username: username,
        password: password,
        remember: remember,
      );
      final response = await remoteDataSource.login(request);
      return response.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    return _handleExceptions<Unit>(() async {
      await remoteDataSource.logout();
      return unit;
    });
  }
}
