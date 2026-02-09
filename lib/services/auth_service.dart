import 'package:chronoflow/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chronoflow/states/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SecureStorageService _storageService;
  
  AuthService(this._storageService);
  Future<bool> isLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }

  Future<AuthState> signInWithGoogle() async {
    // Implement Google Sign-In logic here
    // This is a placeholder for the actual implementation
    try {
      // Simulate a successful sign-in
      UserCredential? userCredentials;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredentials = await _auth.signInWithPopup(googleProvider);
      } else {
        // Trigger the authentication flow
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance
            .authenticate();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        // Once signed in, return the UserCredentia
        userCredentials = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        if (userCredentials.credential?.accessToken != null) {
          await _storageService.saveValue('jwttoken', userCredentials.credential!.accessToken!);
        }
      }
      if (userCredentials.user != null) {
        return AuthState(isLoggedIn: true);
      } else {
        return AuthState(errorMessage: 'Google Sign-In failed');
      }
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return AuthState(errorMessage: e.toString());
    }
  }

  Future<AuthState> signOut() async {
    try {
      await _auth.signOut();
      return AuthState(isLoggedIn: false);
    } catch (e) {
      debugPrint('Error during sign out: $e');
      return AuthState(isLoggedIn: true, errorMessage: e.toString());
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
