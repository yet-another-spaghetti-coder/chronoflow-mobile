
import 'package:chronoflow/providers/storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:chronoflow/notifiers/auth_notifier.dart';
import 'package:chronoflow/services/auth_service.dart';
import 'package:chronoflow/states/auth_state.dart';

final authServiceProvider = Provider<AuthService>((ref){
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  return AuthService(secureStorageService);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState> ((ref){
  
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);

});