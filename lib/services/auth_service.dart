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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SecureStorageService _storageService;
  final HttpClient client = HttpClient();

  bool _isInitialized = false;

  AuthService(this._storageService);

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        serverClientId: '521897010746-eub5olv0ribkc50pbaicuqbjjkkakl81.apps.googleusercontent.com',
      );
      _isInitialized = true;
    }
  }

  Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    return user != null;
  }

  Future<AuthState> signInWithGoogle() async {
    try {
      await _ensureInitialized();
      UserCredential? userCredentials;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        userCredentials = await _auth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await _googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        userCredentials = await _auth.signInWithCredential(credential);
      }

      final token = await userCredentials.user?.getIdToken();
      if (token != null) {
        await _storageService.saveToken(token);
        return AuthState(isLoggedIn: true);
      } else {
        return AuthState(errorMessage: 'Failed to retrieve Firebase ID Token');
      }
    } on Exception catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return AuthState(errorMessage: e.toString());
    }
  }

  Future<AuthState> signUp(OrganiserRegistration orgReg) async {
    try {
      await _ensureInitialized();

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final token = await userCredential.user?.getIdToken();

      if (token != null) {
        final formPayload = orgReg.toJson();

        await client.post(Constants.registerOrganizerEndpoint, {}, {
          'jwtToken': token,
          ...formPayload,
        });
      }
      return signOut();
    } on Exception catch (e) {
      debugPrint('Error during Google Sign-Up: $e');
      return AuthState(errorMessage: e.toString());
    }
  }

  Future<AuthState> signOut() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.disconnect();
      await _auth.signOut();
      await _storageService.deleteToken();
      await _storageService.deleteRefreshCookie();
      await _storageService.deleteAuthorizationCookie();
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
