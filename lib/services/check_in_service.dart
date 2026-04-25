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

  Future<String?> _getCookieHeader() async {
    final refreshCookie = await _storageService.getRefreshCookie();
    final authorizationCookie = await _storageService.getAuthorizationCookie();

    final parts = <String>[];

    if (refreshCookie != null && refreshCookie.isNotEmpty) {
      if (refreshCookie.contains('=')) {
        parts.add(refreshCookie);
      } else {
        parts.add('refreshToken=$refreshCookie');
      }
    }

    if (authorizationCookie != null && authorizationCookie.isNotEmpty) {
      if (authorizationCookie.contains('=')) {
        parts.add(authorizationCookie);
      } else {
        parts.add('Authorization=$authorizationCookie');
      }
    }

    if (parts.isNotEmpty) {
      return parts.join('; ');
    }

    return null;
  }

  Future<Either<String, String>> checkIn(String qrCode) async {
    final token = extractTokenFromUrl(qrCode);
    if (token == null || token.isEmpty) {
      return const Left('Invalid QR code format. No token found.');
    }

    final cookieHeader = await _getCookieHeader();
    if (cookieHeader == null || cookieHeader.isEmpty) {
      return const Left('Authentication required. Please log in again.');
    }

    try {
      await _httpClient.post(
        '/attendees/staff-scan',
        {'Cookie': cookieHeader},
        {'token': token},
      );
      return const Right('Check-in successful');
    } on Exception catch (e) {
      final message = e.toString();
      final cleaned = message.startsWith('Exception: ') ? message.substring('Exception: '.length) : message;
      return Left(cleaned);
    }
  }
}
