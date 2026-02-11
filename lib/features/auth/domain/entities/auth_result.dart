import 'package:chronoflow/features/auth/domain/entities/role.dart';
import 'package:chronoflow/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class AuthResult extends Equatable {
  final User user;
  final List<Role> roles;

  const AuthResult({
    required this.user,
    required this.roles,
  });

  @override
  List<Object?> get props => [user, roles];
}
