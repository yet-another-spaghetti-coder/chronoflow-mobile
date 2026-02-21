import 'package:chronoflow/services/http_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final httpClientProvider = Provider<HttpClient>((ref) {
  return HttpClient();
});
