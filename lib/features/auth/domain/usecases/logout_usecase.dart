import 'package:chronoflow/core/errors/failures.dart';
import 'package:chronoflow/core/usecase/usecase.dart';
import 'package:chronoflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LogoutUseCase implements UseCase<Unit, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return repository.logout();
  }
}
