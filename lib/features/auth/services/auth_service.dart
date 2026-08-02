import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';
import 'package:sgrv_frontend/features/auth/models/login_response.dart';

class AuthService {
  Future<void> login({
    required String correo,
    required String contrasena,
  }) async {
    final uri = Uri.parse(ApiConfig.login);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': correo, 'password': contrasena}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final loginResponse = LoginResponse.fromJson(json);

      if (loginResponse.token.isEmpty) {
        throw Exception(
          'El servidor respondió correctamente, pero no devolvió el token.',
        );
      }

      await TokenStorage.saveToken(loginResponse.token);

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
