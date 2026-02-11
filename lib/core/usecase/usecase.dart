import 'package:chronoflow/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

// ignore: one_member_abstracts
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {}
