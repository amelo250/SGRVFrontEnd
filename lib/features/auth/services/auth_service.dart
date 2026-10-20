import 'package:sgrv_frontend/core/session/session_state.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';
import 'package:sgrv_frontend/features/auth/models/login_response.dart';

class AuthService {
  Future<void> login({
    required String correo,
    required String contrasena,
  }) async {
    final generation = SessionState.generation.value;
    final uri = Uri.parse(ApiConfig.login);

    final http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': correo, 'password': contrasena}),
          )
          .timeout(ApiConfig.timeout);
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar con el servidor. '
        'Verifique su conexión y la dirección del servicio configurada.',
      );
    } on TimeoutException {
      throw Exception(
        'El servidor tardó demasiado en responder. Intente nuevamente.',
      );
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final apiResponse = ApiResponse<LoginResponse>.fromJson(
        json,
        (value) => LoginResponse.fromJson(value! as Map<String, dynamic>),
      );
      final loginResponse = apiResponse.data;

      if (!apiResponse.success ||
          loginResponse == null ||
          loginResponse.token.isEmpty) {
        throw Exception(
          apiResponse.message.isEmpty
              ? 'El servidor respondió correctamente, pero no devolvió el token.'
              : apiResponse.message,
        );
      }

      await TokenStorage.saveToken(loginResponse.token, expectedGeneration: generation);

      return;
    }

    if (response.statusCode == 400) {
      throw Exception('Los datos introducidos no son válidos.');
    }

    if (response.statusCode == 401) {
      throw Exception('Correo o contraseña incorrectos.');
    }

    throw Exception(
      'No fue posible iniciar sesión. Código ${response.statusCode}.',
    );
  }

  Future<void> logout() async {
    await TokenStorage.deleteToken();
  }

  Future<bool> isAuthenticated() async {
    return TokenStorage.hasToken();
  }
}
