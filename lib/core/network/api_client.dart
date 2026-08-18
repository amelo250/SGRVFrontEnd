import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, String>> _buildHeaders({
    bool includeAuthorization = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
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
    return _client
        .get(Uri.parse(url), headers: await _buildHeaders())
        .timeout(ApiConfig.timeout);
  }

  Future<http.Response> post(
    String url, {
    Object? body,
    bool includeAuthorization = true,
  }) async {
    return _client
        .post(
          Uri.parse(url),
          headers: await _buildHeaders(
            includeAuthorization: includeAuthorization,
          ),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
  }

  Future<http.Response> put(String url, {Object? body}) async {
    return _client
        .put(
          Uri.parse(url),
          headers: await _buildHeaders(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
  }

  Future<http.Response> patch(String url, {Object? body}) async {
    return _client
        .patch(
          Uri.parse(url),
          headers: await _buildHeaders(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
  }

  Future<http.Response> delete(String url) async {
    return _client
        .delete(Uri.parse(url), headers: await _buildHeaders())
        .timeout(ApiConfig.timeout);
  }

  Future<Map<String, dynamic>> multipart(
    String url, {
    required List<int> bytes,
    required String fileName,
    required String contentType,
    Map<String, String> fields = const {},
    String fileField = 'archivo',
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);
    request.files.add(
      http.MultipartFile.fromBytes(
        fileField,
        bytes,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      ),
    );
    final streamed = await _client.send(request).timeout(ApiConfig.timeout);
    return _decode(await http.Response.fromStream(streamed));
  }

  Future<ApiJsonResult> getJsonResult(String url) async {
    final response = await get(url);

    return ApiJsonResult(
      json: await _decode(response),
      headers: Map.unmodifiable(response.headers),
    );
  }

  Future<Map<String, dynamic>> getJson(String url) async {
    return _decode(await get(url));
  }

  Future<List<int>> getBytes(String url) async {
    final response = await get(url);
    if (response.statusCode == 401) {
      await TokenStorage.deleteToken();
      throw const ApiException(
        message: 'La sesión expiró. Inicia sesión nuevamente.',
        statusCode: 401,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: 'No fue posible recuperar el archivo.',
        statusCode: response.statusCode,
      );
    }
    return response.bodyBytes;
  }

  Future<Map<String, dynamic>> postJson(String url, Object body) async {
    return _decode(await post(url, body: body));
  }

  Future<Map<String, dynamic>> putJson(String url, Object body) async {
    return _decode(await put(url, body: body));
  }

  Future<Map<String, dynamic>> patchJson(String url, {Object? body}) async {
    return _decode(await patch(url, body: body));
  }

  Future<Map<String, dynamic>> deleteJson(String url) async {
    return _decode(await delete(url));
  }

  Future<Map<String, dynamic>> _decode(http.Response response) async {
    Map<String, dynamic> json = <String, dynamic>{};
    if (response.body.trim().isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      } else {
        throw ApiException(
          message: 'La API devolvió un formato no válido.',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode == 401) {
      await TokenStorage.deleteToken();
      throw const ApiException(
        message: 'La sesión expiró. Inicia sesión nuevamente.',
        statusCode: 401,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message:
            json['message']?.toString() ??
            'No fue posible completar la operación.',
        statusCode: response.statusCode,
      );
    }

    return json;
  }

  void dispose() => _client.close();
}

class ApiJsonResult {
  const ApiJsonResult({required this.json, required this.headers});

  final Map<String, dynamic> json;
  final Map<String, String> headers;
}
