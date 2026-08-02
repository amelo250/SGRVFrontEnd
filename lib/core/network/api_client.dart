import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sgrv_frontend/core/storage/token_storage.dart';

class ApiClient {
  Future<Map<String, String>> _buildHeaders({
    bool includeAuthorization = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuthorization) {
      final token = await TokenStorage.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> get(String url) async {
    return http.get(Uri.parse(url), headers: await _buildHeaders());
  }

  Future<http.Response> post(
    String url, {
    Object? body,
    bool includeAuthorization = true,
  }) async {
    return http.post(
      Uri.parse(url),
      headers: await _buildHeaders(includeAuthorization: includeAuthorization),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> put(String url, {Object? body}) async {
    return http.put(
      Uri.parse(url),
      headers: await _buildHeaders(),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> delete(String url) async {
    return http.delete(Uri.parse(url), headers: await _buildHeaders());
  }
}
