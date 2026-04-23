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

  final AndroidOptions _androidOptions = const AndroidOptions(
    sharedPreferencesName: 'ChronoflowAccount',
  );

  SecureStorageService(this._storage);

  Future<void> saveToken(String token) async {
    switch (Platform.operatingSystem) {
      case 'ios':
        await _storage.write(key: _jwtTokenKey, value: token, iOptions: _iosOptions);
      case 'android':
        await _storage.write(key: _jwtTokenKey, value: token, aOptions: _androidOptions);
      default:
        await _storage.write(key: _jwtTokenKey, value: token);
    }
  }

  Future<String?> getToken() {
    switch (Platform.operatingSystem) {
      case 'ios':
        return _storage.read(key: _jwtTokenKey, iOptions: _iosOptions);
      case 'android':
        return _storage.read(key: _jwtTokenKey, aOptions: _androidOptions);
      default:
        {
          return _storage.read(key: _jwtTokenKey);
        }
    }
  }

  Future<void> deleteToken() async {
    switch (Platform.operatingSystem) {
      case 'ios':
        return _storage.delete(key: _jwtTokenKey, iOptions: _iosOptions);
      case 'android':
        return _storage.delete(key: _jwtTokenKey, aOptions: _androidOptions);
      default:
        return _storage.delete(key: _jwtTokenKey);
    }
  }

  Future<void> saveRefreshCookie(String cookie) async {
    switch (Platform.operatingSystem) {
      case 'ios':
        {
          await _storage.write(key: _refreshCookieKey, value: cookie, iOptions: _iosOptions);
        }
      case 'android':
        {
          await _storage.write(key: _refreshCookieKey, value: cookie, aOptions: _androidOptions);
        }
      default:
        {
          await _storage.write(key: _refreshCookieKey, value: cookie);
        }
    }
  }

  Future<String?> getRefreshCookie() {
    switch (Platform.operatingSystem) {
      case 'ios':
        {
          return _storage.read(key: _refreshCookieKey, iOptions: _iosOptions);
        }
      case 'android':
        {
          return _storage.read(key: _refreshCookieKey, aOptions: _androidOptions);
        }
      default:
        {
          return _storage.read(key: _refreshCookieKey);
        }
    }
  }

  Future<void> deleteRefreshCookie() async {
    switch (Platform.operatingSystem) {
      case 'ios':
        {
          return _storage.delete(key: _refreshCookieKey, iOptions: _iosOptions);
        }
      case 'android':
        {
          return _storage.delete(key: _refreshCookieKey, aOptions: _androidOptions);
        }
      default:
        {
          return _storage.delete(key: _refreshCookieKey);
        }
    }
  }

  Future<void> saveAuthorizationCookie(String cookie) async {
    switch (Platform.operatingSystem) {
      case 'ios':
        {
          await _storage.write(key: _authorizationCookieKey, value: cookie, iOptions: _iosOptions);
        }
      case 'android':
        {
          await _storage.write(key: _authorizationCookieKey, value: cookie, aOptions: _androidOptions);
        }
      default:
        {
          await _storage.write(key: _authorizationCookieKey, value: cookie);
        }
    }
  }

  Future<String?> getAuthorizationCookie() {
    switch (Platform.operatingSystem) {
      case 'ios':
        {
          return _storage.read(key: _authorizationCookieKey, iOptions: _iosOptions);
        }
      case 'android':
        {
          return _storage.read(key: _authorizationCookieKey, aOptions: _androidOptions);
        }
      default:
        {
          return _storage.read(key: _authorizationCookieKey);
        }
    }
  }

  Future<void> deleteAuthorizationCookie() async {
    switch (Platform.operatingSystem) {
      case 'ios':
        {
          return _storage.delete(key: _authorizationCookieKey, iOptions: _iosOptions);
        }
      case 'android':
        {
          return _storage.delete(key: _authorizationCookieKey, aOptions: _androidOptions);
        }
      default:
        {
          return _storage.delete(key: _authorizationCookieKey);
        }
    }
  }
}
