import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  final IOSOptions _iosOptions = const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock, // accessible after first unlock post-reboot
    accountName: 'ChronoflowAccount',                       // groups keys under one keychain account
  );
  SecureStorageService(this._storage);

  Future<void> saveToken(String token) async {
    if (Platform.isIOS) {
      await _storage.write(key: 'jwt_token', value: token, iOptions: _iosOptions);
    } else {
      await _storage.write(key: 'jwt_token', value: token);
    }
  }

  Future<String?> getToken() {
    if (Platform.isIOS) {
      return _storage.read(key: 'jwt_token', iOptions: _iosOptions);
    } else {
      return _storage.read(key: 'jwt_token');
    }
  }

  Future<void> deleteToken() async {
    if (Platform.isIOS) {
      return _storage.delete(key: 'jwt_token', iOptions: _iosOptions);
    } else {
      return _storage.delete(key: 'jwt_token');
    }
  }
}
