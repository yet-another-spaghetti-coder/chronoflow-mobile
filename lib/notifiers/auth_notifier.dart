import 'package:chronoflow/models/organiser_registration.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:chronoflow/services/auth_service.dart';
import 'package:chronoflow/states/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _firebaseService;
  AuthNotifier(this._firebaseService) : super(AuthState(isLoggedIn: false));
  Future<void> checkLoginStatus() async =>
      state = AuthState(isLoggedIn: await _firebaseService.isLoggedIn());
  Future<void> signIn() async =>
      state = await _firebaseService.signInWithGoogle();
  Future<void> signOut() async => state = await _firebaseService.signOut();
  Future<void> signUp(OrganiserRegistration orgReg) async =>
      await _firebaseService.signUp(orgReg);
}
