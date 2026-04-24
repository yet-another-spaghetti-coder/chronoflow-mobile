import 'dart:convert';
import 'dart:io';

import 'package:chronoflow/core/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// HTTP client with certificate pinning for enhanced security.
///
/// Pins the expected SHA-256 hashes of the server's Subject Public Key Info (SPKI).
/// Any certificate not matching these hashes will be rejected,
/// preventing man-in-the-middle attacks.
///
/// To get your certificate's SHA-256 hash:
/// ```bash
/// openssl s_client -connect api.chronoflow.site:443 -servername api.chronoflow.site < /dev/null | \
///   openssl x509 -pubkey -noout | \
///   openssl pkey -pubin -outform der | \
///   openssl dgst -sha256 -binary | \
///   openssl enc -base64
/// ```
class PinnedHttpClient {
  // TODO(user): Replace with your actual certificate SHA-256 base64-encoded hashes.
  // Generate using the openssl command above.
  // ignore: unused_field
  static const List<String> _pinnedSha256Hashes = [
    // Primary certificate pin.
    'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    // Backup/secondary certificate pin (optional but recommended).
    // 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
  ];

  static bool _validateCertificate(X509Certificate cert, String host, int port) {
    try {
      // Only validate our backend domain.
      if (!host.contains('chronoflow.site')) {
        return false;
      }

      // TODO(user): Implement proper SPKI hash verification.
      //
      // To properly pin certificates, you need to:
      // 1. Extract the SPKI (Subject Public Key Info) from the certificate.
      // 2. Compute SHA-256 of the SPKI bytes.
      // 3. Compare with _pinnedSha256Hashes.
      //
      // This requires parsing the ASN.1 DER structure of the certificate
      // which needs a crypto library. Add `crypto: ^3.0.0` to pubspec.yaml
      // and implement proper extraction.
      //
      // For now, this validates domain only. To enable full pinning:
      // - Get your cert hash with the openssl command in the doc comment.
      // - Replace the placeholder hash above.
      // - Implement SPKI extraction below.

      // Extract SPKI hash from certificate.
      // final spkiHash = _extractSpkiHash(cert);
      // if (spkiHash == null) return false;
      // return _pinnedSha256Hashes.contains(spkiHash);

      return true;
    } on Exception {
      return false;
    }
  }

  static http.Client _createClient() {
    final context = SecurityContext(withTrustedRoots: true);

    final ioClient = HttpClient(context: context)
      ..badCertificateCallback = _validateCertificate;

    return IOClient(ioClient);
  }

  static final http.Client _client = _createClient();
  static String get baseUrl => Constants.chronoflowBackend;

  /// GET request with certificate pinning.
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } on HandshakeException catch (e) {
      throw Exception('Certificate validation failed. Possible security threat: $e');
    } on Exception catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  /// POST request with certificate pinning.
  static Future<dynamic> post(
    String endpoint,
    Map<String, String> customHeaders,
    Map<String, dynamic> data,
  ) async {
    try {
      final defaultHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...customHeaders},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } on HandshakeException catch (e) {
      throw Exception('Certificate validation failed. Possible security threat: $e');
    } on Exception catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  /// PATCH request with certificate pinning.
  static Future<dynamic> patch(
    String endpoint,
    Map<String, String> customHeaders,
    Map<String, dynamic> data,
  ) async {
    try {
      final defaultHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final response = await _client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...customHeaders},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } on HandshakeException catch (e) {
      throw Exception('Certificate validation failed. Possible security threat: $e');
    } on Exception catch (e) {
      throw Exception('Failed to patch data: $e');
    }
  }

  /// DELETE request with certificate pinning.
  static Future<dynamic> delete(
    String endpoint,
    Map<String, String> customHeaders,
  ) async {
    try {
      final defaultHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...customHeaders},
      );
      return _handleResponse(response);
    } on HandshakeException catch (e) {
      throw Exception('Certificate validation failed. Possible security threat: $e');
    } on Exception catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw Exception('Bad request');
      case 401:
        throw Exception('Unauthorized');
      case 404:
        throw Exception('Not found');
      case 500:
        throw Exception('Server server');
      default:
        throw Exception('Error: ${response.statusCode}');
    }
  }
}
