import 'dart:convert';
import 'package:chronoflow/core/constants.dart';
import 'package:http/http.dart' as http;

class HttpClient {
  String baseUrl = Constants.chronoflowBackend;

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, Map<String, String> customHeaders, Map<String, dynamic> data) async {
    try {
      final defaultHeaders = {
        'Accept': 'application/json',
        'Content-Type':'application/json'
      };
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...customHeaders},
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
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
        throw Exception('Server error');
      default:
        throw Exception('Error: ${response.statusCode}');
    }
  }
}
