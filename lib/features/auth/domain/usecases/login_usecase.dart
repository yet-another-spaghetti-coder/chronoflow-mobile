import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/core/usecase/usecase.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';
import 'package:chronoflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LoginUseCase implements UseCase<AuthResult, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(LoginParams params) async {
    return await repository.login(
      username: params.username,
      password: params.password,
      remember: params.remember,
    );
  }
}

class LoginParams {
  final String username;
  final String password;
  final bool remember;

  LoginParams({
    required this.username,
    required this.password,
    this.remember = false,
  });
}
