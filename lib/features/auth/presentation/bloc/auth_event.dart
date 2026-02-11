import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final bool remember;

  const LoginRequested({
    required this.username,
    required this.password,
    this.remember = false,
  });

  @override
  List<Object?> get props => [username, password, remember];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
