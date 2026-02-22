import 'package:chronoflow/notifiers/check_in_notifier.dart';
import 'package:chronoflow/providers/http_client_provider.dart';
import 'package:chronoflow/providers/storage_provider.dart';
import 'package:chronoflow/services/check_in_service.dart';
import 'package:chronoflow/states/check_in_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final checkInServiceProvider = Provider<CheckInService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  return CheckInService(httpClient, storageService);
});

final checkInNotifierProvider = StateNotifierProvider<CheckInNotifier, CheckInState>((ref) {
  final checkInService = ref.watch(checkInServiceProvider);
  return CheckInNotifier(checkInService);
});
