import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/models/api_response.dart';
import 'package:chronoflow/models/organiser_registration.dart';
import 'package:chronoflow/services/http_client.dart';
import 'package:chronoflow/services/storage_service.dart';
import 'package:chronoflow/states/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SecureStorageService _storageService;
  final HttpClient client = HttpClient();
  AuthService(this._storageService);
  Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    return user != null;
  }

  Future<AuthState> signInWithGoogle() async {
    // Implement Google Sign-In logic here
    // This is a placeholder for the actual implementation
    try {
      // Simulate a successful sign-in
      UserCredential? userCredentials;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        userCredentials = await _auth.signInWithPopup(googleProvider);
      } else {
        // Trigger the authentication flow
        final googleUser = await GoogleSignIn.instance.authenticate();

        // Obtain the auth details from the request
        final googleAuth = googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        // Once signed in, return the UserCredentia
        userCredentials = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        if (userCredentials.credential?.accessToken != null) {
          await _storageService.saveToken(
            userCredentials.credential!.accessToken!,
          );
        }
      }
      if (userCredentials.user != null) {
        return AuthState(isLoggedIn: true);
      } else {
        return AuthState(errorMessage: 'Google Sign-In failed');
      }
    } on Exception catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return AuthState(errorMessage: e.toString());
    }
  }

  Future<AuthState> signUp(OrganiserRegistration orgReg) async {
    final googleUser = await GoogleSignIn.instance.authenticate();

    // Obtain the auth details from the request
    final googleAuth = googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    // Once signed in, return the UserCredentia
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    if (userCredential.credential?.accessToken != null) {
      final formPayload = orgReg.toJson();

      await client.post(Constants.registerOrganizerEndpoint, {}, {
        'jwtToken': userCredential.credential!.accessToken,
        ...formPayload,
      });
    }
    return signOut();
  }

  Future<AuthState> signOut() async {
    try {
      await _auth.signOut();
      await _storageService.deleteToken();
      return AuthState();
    } on Exception catch (e) {
      debugPrint('Error during sign out: $e');
      return AuthState(isLoggedIn: true, errorMessage: e.toString());
    }
  }

  Future<String> exchangeToken() async {
    final jwtToken = await _storageService.getToken();
    final headers = {
      'Authorization': 'Bearer $jwtToken',
    };
    final result = await client.post(Constants.tokenExchangeEndpoint, headers, {}) as Map<String, dynamic>;
    final responseBody = ApiResponse.fromJson(result);
    return responseBody.data.toString();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
