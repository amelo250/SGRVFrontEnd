import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';
import 'package:sgrv_frontend/core/session/session_state.dart';

class PasswordService {
  PasswordService({http.Client? client, ApiClient? authenticatedClient})
    : _public = client ?? http.Client(),
      _authenticated = authenticatedClient ?? ApiClient();
  final http.Client _public;
  final ApiClient _authenticated;

  Future<String> _post(String path, Map<String, dynamic> body) async {
    final response = await _public
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/Auth/$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } on FormatException {
      throw ApiException(
        message: 'No fue posible completar la operación. Inténtalo nuevamente.',
        statusCode: response.statusCode,
      );
    }
    final message =
        data['message']?.toString() ?? 'No fue posible completar la operación.';
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(message: message, statusCode: response.statusCode);
    }
    return message;
  }

  Future<String> request(String email) =>
      _post('recuperar-password', {'email': email.trim()});
  Future<String> recover(String code, String password, String confirmation) =>
      _post('restablecer-password', {
        'codigo': code.trim(),
        'passwordNueva': password,
        'confirmarPassword': confirmation,
      });

  Future<void> change(
    String current,
    String password,
    String confirmation,
  ) async {
    final generation = SessionState.generation.value;
    final id = await _currentId();
    SessionState.requireCurrent(generation);
    final result = await _authenticated.patchJson(
      '${ApiConfig.usuarios}/$id/cambiar-password',
      body: {
        'passwordActual': current,
        'passwordNueva': password,
        'confirmarPassword': confirmation,
      },
    );
    if (result['success'] != true) {
      throw ApiException(
        message:
            result['message']?.toString() ??
            'No se pudo cambiar la contraseña.',
      );
    }
    await TokenStorage.deleteToken(expectedGeneration: generation);
  }

  Future<void> reset(
    int user,
    int company,
    String password,
    String confirmation,
  ) async {
    final generation = SessionState.generation.value;
    final self = user == await _currentId();
    SessionState.requireCurrent(generation);
    final result = await _authenticated.patchJson(
      '${ApiConfig.usuarios}/$user/restablecer-password',
      body: {
        'idEmpresa': company,
        'passwordNueva': password,
        'confirmarPassword': confirmation,
      },
    );
    if (result['success'] != true) {
      throw ApiException(
        message:
            result['message']?.toString() ??
            'No se pudo restablecer la contraseña.',
      );
    }
    if (self) await TokenStorage.deleteToken(expectedGeneration: generation);
  }

  Future<int> _currentId() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw const ApiException(message: 'Inicia sesión nuevamente.');
    }
    final parts = token.split('.');
    final payload =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
            as Map<String, dynamic>;
    return int.parse(payload['UsuarioId'].toString());
  }

  void dispose() {
    _public.close();
    _authenticated.dispose();
  }
}
