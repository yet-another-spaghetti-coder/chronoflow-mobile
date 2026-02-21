import 'package:chronoflow/services/http_client.dart';
import 'package:chronoflow/services/storage_service.dart';
import 'package:fpdart/fpdart.dart';

class CheckInService {
  final HttpClient _httpClient;
  final SecureStorageService _storageService;

  CheckInService(this._httpClient, this._storageService);

  String? extractTokenFromUrl(String qrCode) {
    try {
      final uri = Uri.parse(qrCode);
      return uri.queryParameters['token'];
    } on FormatException {
      return null;
    } on Exception {
      return null;
    }
  }

  Future<Either<String, String>> checkIn(String qrCode) async {
    final token = extractTokenFromUrl(qrCode);
    if (token == null || token.isEmpty) {
      return const Left('Invalid QR code format. No token found.');
    }

    final jwtToken = await _storageService.getToken();
    if (jwtToken == null || jwtToken.isEmpty) {
      return const Left('Authentication required. Please log in again.');
    }

    try {
      await _httpClient.post(
        '/attendees/staff-scan',
        {'token': token},
        headers: {'Authorization': 'Bearer $jwtToken'},
      );
      return const Right('Check-in successful');
    } on Exception catch (e) {
      final message = e.toString();
      final cleaned = message.startsWith('Exception: ') ? message.substring('Exception: '.length) : message;
      return Left(cleaned);
    }
  }
}
