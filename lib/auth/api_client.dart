import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  // Replace with your actual backend URL
  static const String baseUrl = 'http://localhost:5000';
  final GoogleAuthService _authService = GoogleAuthService();

  // GET request with automatic token refresh
  Future<http.Response> get(String endpoint) async {
    return _makeRequest(() async {
      final token = await _authService.getAccessToken();
      return http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    });
  }

  // POST request with automatic token refresh
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return _makeRequest(() async {
      final token = await _authService.getAccessToken();
      return http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    });
  }

  // PUT request with automatic token refresh
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    return _makeRequest(() async {
      final token = await _authService.getAccessToken();
      return http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    });
  }

  // DELETE request with automatic token refresh
  Future<http.Response> delete(String endpoint) async {
    return _makeRequest(() async {
      final token = await _authService.getAccessToken();
      return http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    });
  }

  // Helper method to handle token refresh
  Future<http.Response> _makeRequest(Future<http.Response> Function() request) async {
    var response = await request();

    // If unauthorized, try to refresh token and retry
    if (response.statusCode == 401) {
      final newToken = await _authService.refreshAccessToken();
      if (newToken != null) {
        // Retry request with new token
        response = await request();
      }
    }

    return response;
  }
}