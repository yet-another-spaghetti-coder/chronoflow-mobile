import 'package:chronoflow/providers/http_client_provider.dart';
import 'package:chronoflow/providers/storage_provider.dart';
import 'package:chronoflow/services/check_in_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkInServiceProvider = Provider<CheckInService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  return CheckInService(httpClient, storageService);
});
