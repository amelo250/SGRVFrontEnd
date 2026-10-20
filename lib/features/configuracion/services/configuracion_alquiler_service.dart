import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';

class ConfiguracionAlquilerService {
  ConfiguracionAlquilerService({ApiClient? client})
    : _client = client ?? ApiClient();
  final ApiClient _client;
  String get _url => '${ApiConfig.baseUrl}/api/configuracion/empresa/alquiler';
  Future<bool> get() async => _parse(await _client.getJson(_url));
  Future<bool> save(bool value, bool expected) async => _parse(
    await _client.putJson(_url, {
      'capturarHorasPeriodoAlquiler': value,
      'valorEsperado': expected,
    }),
  );
  static bool _parse(Map<String, dynamic> json) {
    final response = ApiResponse<bool>.fromJson(
      json,
      (value) =>
          (value as Map<String, dynamic>)['capturarHorasPeriodoAlquiler']
              as bool,
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  void dispose() => _client.dispose();
}
