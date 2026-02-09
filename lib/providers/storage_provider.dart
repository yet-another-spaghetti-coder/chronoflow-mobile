import 'package:chronoflow/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



// Provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = const FlutterSecureStorage();
  return SecureStorageService(storage);
});