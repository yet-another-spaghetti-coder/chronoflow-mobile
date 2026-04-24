import 'dart:convert';

import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/models/api_response.dart';
import 'package:chronoflow/models/organiser_registration.dart';
import 'package:chronoflow/services/http_client.dart';
import 'package:chronoflow/services/storage_service.dart';
import 'package:chronoflow/states/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SecureStorageService _storageService;
  final HttpClient _client = HttpClient();

  bool _isInitialized = false;

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

      final token = await userCredentials.user?.getIdToken();

      if (token != null) {
        try {
          // Use raw http to access response headers (cookies)
          final response = await http.post(
            Uri.parse('${Constants.chronoflowBackend}${Constants.firebaseLoginEndpoint}'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({}),
          );

          if (response.statusCode == 200) {
            final result = jsonDecode(response.body) as Map<String, dynamic>;
            final responseBody = ApiResponse.fromJson(result);
            debugPrint('Firebase Login Response: ${responseBody.data}');

            // Extract and store cookies from response
            final setCookie = response.headers['set-cookie'];
            if (setCookie != null && setCookie.isNotEmpty) {
              final refreshToken = _extractCookieValue(setCookie, 'refreshToken');
              final authorization = _extractCookieValue(setCookie, 'Authorization');

              if (refreshToken != null && refreshToken.isNotEmpty) {
                await _storageService.saveRefreshCookie('refreshToken=$refreshToken');
              }
              if (authorization != null && authorization.isNotEmpty) {
                await _storageService.saveAuthorizationCookie('Authorization=$authorization');
              }
            }
          } else {
            debugPrint('Firebase Login HTTP error: ${response.statusCode}');
          }
        } on Exception catch (e) {
          debugPrint('Error during token exchange: $e');
        }

        await _storageService.saveToken(token);
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

        await _client.post(Constants.registerOrganizerEndpoint, {}, {
          'jwtToken': token,
          ...formPayload,
        });
      }
      return signOut();
    } on Exception catch (e) {
      debugPrint('Error during Google Sign-Up: $e');
      return AuthState(errorMessage: e.toString());
    }
    return signOut();
  }

  Future<AuthState> signOut() async {
    try {
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
    final result = await _client.post(Constants.tokenExchangeEndpoint, headers, {}) as Map<String, dynamic>;
    final responseBody = ApiResponse.fromJson(result);
    return responseBody.data.toString();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  String? _extractCookieValue(String rawSetCookie, String cookieName) {
    final match = RegExp('${RegExp.escape(cookieName)}=([^;]+)').firstMatch(rawSetCookie);
    return match?.group(1)?.trim();
  }
}
