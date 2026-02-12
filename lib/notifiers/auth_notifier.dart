import 'package:chronoflow/models/organiser_registration.dart';
import 'package:chronoflow/services/auth_service.dart';
import 'package:chronoflow/states/auth_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  AuthNotifier(this._authService) : super(AuthState());
  Future<void> checkLoginStatus() async =>
      state = AuthState(isLoggedIn: await _authService.isLoggedIn());
  Future<void> signIn() async =>
      state = await _authService.signInWithGoogle();
  Future<void> signOut() async => state = await _authService.signOut();
  Future<void> signUp(OrganiserRegistration orgReg) async => _authService.signUp(orgReg);
}
