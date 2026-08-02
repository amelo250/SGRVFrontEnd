import 'dart:convert';

import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/features/empresas/models/empresa.dart';

class EmpresaService {
  final ApiClient _apiClient;

  EmpresaService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Empresa>> getEmpresas() async {
    final response = await _apiClient.get(ApiConfig.empresas);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

      return jsonList
          .map((item) => Empresa.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('La sesión expiró o el token no es válido.');
    }

    if (response.statusCode == 403) {
      throw Exception('No tienes permisos para consultar empresas.');
    }

    throw Exception(
      'Error consultando empresas. Código ${response.statusCode}.',
    );
  }
}
