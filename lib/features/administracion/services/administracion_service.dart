import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import '../models/administracion_resumen.dart';

class AdministracionService {
  AdministracionService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<AdministracionResumen> getResumen() async {
    final response = ApiResponse<AdministracionResumen>.fromJson(
      await _client.getJson(ApiConfig.administracionResumen),
      (value) => AdministracionResumen.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  void dispose() => _client.dispose();
}
