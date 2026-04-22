import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  static const String _jwtTokenKey = 'jwt_token';
  static const String _refreshCookieKey = 'refresh_cookie';
  static const String _authorizationCookieKey = 'authorization_cookie';
  final IOSOptions _iosOptions = const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock, // accessible after first unlock post-reboot
    accountName: 'ChronoflowAccount', // groups keys under one keychain account
  );
  SecureStorageService(this._storage);

  Future<void> saveToken(String token) async {
    if (Platform.isIOS) {
      await _storage.write(key: _jwtTokenKey, value: token, iOptions: _iosOptions);
    } else {
      await _storage.write(key: _jwtTokenKey, value: token);
    }
  }

  Future<String?> getToken() {
    if (Platform.isIOS) {
      return _storage.read(key: _jwtTokenKey, iOptions: _iosOptions);
    } else {
      return _storage.read(key: _jwtTokenKey);
    }
  }

  Future<void> deleteToken() async {
    if (Platform.isIOS) {
      return _storage.delete(key: _jwtTokenKey, iOptions: _iosOptions);
    } else {
      return _storage.delete(key: _jwtTokenKey);
    }
  }

  Future<void> saveRefreshCookie(String cookie) async {
    if (Platform.isIOS) {
      await _storage.write(
        key: _refreshCookieKey,
        value: cookie,
        iOptions: _iosOptions,
      );
    } else {
      await _storage.write(key: _refreshCookieKey, value: cookie);
    }
  }

  Future<String?> getRefreshCookie() {
    if (Platform.isIOS) {
      return _storage.read(key: _refreshCookieKey, iOptions: _iosOptions);
    } else {
      return _storage.read(key: _refreshCookieKey);
    }
  }

  Future<void> deleteRefreshCookie() async {
    if (Platform.isIOS) {
      return _storage.delete(key: _refreshCookieKey, iOptions: _iosOptions);
    } else {
      return _storage.delete(key: _refreshCookieKey);
    }
  }

  Future<void> saveAuthorizationCookie(String cookie) async {
    if (Platform.isIOS) {
      await _storage.write(
        key: _authorizationCookieKey,
        value: cookie,
        iOptions: _iosOptions,
      );
    } else {
      await _storage.write(key: _authorizationCookieKey, value: cookie);
    }
  }

  Future<String?> getAuthorizationCookie() {
    if (Platform.isIOS) {
      return _storage.read(key: _authorizationCookieKey, iOptions: _iosOptions);
    } else {
      return _storage.read(key: _authorizationCookieKey);
    }
  }

  Future<void> deleteAuthorizationCookie() async {
    if (Platform.isIOS) {
      return _storage.delete(key: _authorizationCookieKey, iOptions: _iosOptions);
    } else {
      return _storage.delete(key: _authorizationCookieKey);
    }
  }
}
