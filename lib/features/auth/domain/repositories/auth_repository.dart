import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login({
    required String username,
    required String password,
    required bool remember,
  });

  Future<Either<Failure, void>> logout();
}
