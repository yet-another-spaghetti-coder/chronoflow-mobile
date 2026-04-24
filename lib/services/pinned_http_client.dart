import 'dart:convert';
import 'dart:io';

import 'package:chronoflow/core/constants.dart';
import 'package:crypto/crypto.dart';
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
  static const List<String> _pinnedSha256Hashes = [
    // Primary certificate pin.
    'QjwkR0/OSehYgg+/6/y8X7soOxfnLtKU/EyDpZ3Ml5Q=',
    // Backup/secondary certificate pin (optional but recommended).
    // 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
  ];

  static bool _validateCertificate(X509Certificate cert, String host, int port) {
    try {
      // Only validate our backend domain.
      if (!host.contains('chronoflow.site')) {
        return false;
      }

      // Extract SPKI hash from certificate and verify.
      final spkiHash = _extractSpkiHash(cert);
      if (spkiHash == null) return false;
      return _pinnedSha256Hashes.contains(spkiHash);
    } on Exception {
      return false;
    }
  }

  /// Extracts the SHA-256 hash of the Subject Public Key Info (SPKI) from a certificate.
  ///
  /// Parses the ASN.1 DER structure to find the public key and computes its SHA-256 hash.
  static String? _extractSpkiHash(X509Certificate cert) {
    try {
      // Remove PEM headers and whitespace to get raw base64.
      final cleanPem = cert.pem
          .replaceAll('-----BEGIN CERTIFICATE-----', '')
          .replaceAll('-----END CERTIFICATE-----', '')
          .replaceAll(RegExp(r'\s'), '');

      // Decode base64 to DER bytes.
      final derBytes = base64Decode(cleanPem);

      // Parse ASN.1 to find SPKI.
      // Certificate SEQUENCE -> TBSCertificate SEQUENCE -> [0] Version, INTEGER Serial,
      // AlgorithmIdentifier, Issuer, Validity, Subject, SubjectPublicKeyInfo
      // SPKI is typically the 7th element in TBSCertificate.
      final spkiBytes = _extractSpkiFromDer(derBytes);
      if (spkiBytes == null || spkiBytes.isEmpty) {
        return null;
      }

      // Compute SHA-256 and base64 encode.
      final hash = sha256.convert(spkiBytes);
      return base64Encode(hash.bytes);
    } on Exception {
      return null;
    }
  }

  /// Extracts SPKI bytes from DER-encoded certificate.
  ///
  /// This is a simplified ASN.1 parser that navigates the certificate structure
  /// to find the SubjectPublicKeyInfo sequence.
  static List<int>? _extractSpkiFromDer(List<int> derBytes) {
    try {
      var offset = 0;

      // Skip outer SEQUENCE wrapper.
      if (derBytes[offset] != 0x30) return null;
      offset += _readLength(derBytes, offset + 1).$2 + 1;

      // Enter TBSCertificate SEQUENCE.
      if (offset >= derBytes.length || derBytes[offset] != 0x30) return null;
      final tbsResult = _readLength(derBytes, offset + 1);
      final tbsStart = offset;
      final tbsEnd = tbsStart + tbsResult.$1 + tbsResult.$2 + 1;
      offset += tbsResult.$2 + 1;

      // Skip: Version ([0] context tag).
      if (offset < tbsEnd && derBytes[offset] == 0xA0) {
        final result = _readLength(derBytes, offset + 1);
        offset += result.$1 + result.$2 + 1;
      }

      // Skip: Serial Number (INTEGER).
      if (offset < tbsEnd && derBytes[offset] == 0x02) {
        final result = _readLength(derBytes, offset + 1);
        offset += result.$1 + result.$2 + 1;
      }

      // Skip: Signature Algorithm (SEQUENCE).
      if (offset < tbsEnd && derBytes[offset] == 0x30) {
        final result = _readLength(derBytes, offset + 1);
        offset += result.$1 + result.$2 + 1;
      }

      // Skip: Issuer (SEQUENCE).
      if (offset < tbsEnd && derBytes[offset] == 0x30) {
        final result = _readLength(derBytes, offset + 1);
        offset += result.$1 + result.$2 + 1;
      }

      // Skip: Validity (SEQUENCE).
      if (offset < tbsEnd && derBytes[offset] == 0x30) {
        final result = _readLength(derBytes, offset + 1);
        offset += result.$1 + result.$2 + 1;
      }

      // Skip: Subject (SEQUENCE).
      if (offset < tbsEnd && derBytes[offset] == 0x30) {
        final result = _readLength(derBytes, offset + 1);
        offset += result.$1 + result.$2 + 1;
      }

      // Current position should be SubjectPublicKeyInfo (SEQUENCE).
      if (offset >= tbsEnd || derBytes[offset] != 0x30) return null;
      final spkiResult = _readLength(derBytes, offset + 1);
      final spkiLength = spkiResult.$1;
      final spkiHeaderLength = spkiResult.$2 + 1;

      // Return full SPKI including SEQUENCE tag and length.
      return derBytes.sublist(offset, offset + spkiHeaderLength + spkiLength);
    } on Exception {
      return null;
    }
  }

  /// Reads an ASN.1 length field and returns (length, bytesRead).
  static (int, int) _readLength(List<int> bytes, int offset) {
    if (offset >= bytes.length) return (0, 0);

    final firstByte = bytes[offset];
    if (firstByte < 0x80) {
      // Short form: length is in the first byte.
      return (firstByte, 1);
    }

    // Long form: number of length bytes = firstByte & 0x7F.
    final numLengthBytes = firstByte & 0x7F;
    if (offset + numLengthBytes >= bytes.length) return (0, 0);

    var length = 0;
    for (var i = 0; i < numLengthBytes; i++) {
      length = (length << 8) | bytes[offset + 1 + i];
    }
    return (length, 1 + numLengthBytes);
  }

  static http.Client _createClient() {
    final context = SecurityContext(withTrustedRoots: true);

    final ioClient = HttpClient(context: context)..badCertificateCallback = _validateCertificate;

    return IOClient(ioClient);
  }

  static final http.Client _client = _createClient();
  static String get baseUrl => Constants.chronoflowBackend;

  /// GET request with certificate pinning.
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    try {
      return await _client.get(url, headers: headers);
    } on HandshakeException catch (e) {
      throw Exception('Certificate validation failed. Possible security threat: $e');
    } on Exception catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  /// POST request with certificate pinning.
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      return await _client.post(url, headers: headers, body: body, encoding: encoding);
    } on HandshakeException catch (e) {
      throw Exception('Certificate validation failed. Possible security threat: $e');
    } on Exception catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  /// PATCH request with certificate pinning.
  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      return await _client.patch(url, headers: headers, body: body, encoding: encoding);
    } on HandshakeException catch (e) {
      throw Exception('Certificate validation failed. Possible security threat: $e');
    } on Exception catch (e) {
      throw Exception('Failed to patch data: $e');
    }
  }

  /// DELETE request with certificate pinning.
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      return await _client.delete(url, headers: headers, body: body, encoding: encoding);
    } on HandshakeException catch (e) {
      throw Exception('Certificate validation failed. Possible security threat: $e');
    } on Exception catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }
}
