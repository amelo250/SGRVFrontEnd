import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';

class CondicionesContratoService {
  CondicionesContratoService({ApiClient? client})
    : _client = client ?? ApiClient();
  final ApiClient _client;
  String get _url => '${ApiConfig.baseUrl}/api/configuracion/empresa/contrato';
  Future<String> get() async => _parse(await _client.getJson(_url));
  Future<String> save(String value, String expected) async => _parse(
    await _client.putJson(_url, {
      'condiciones': value,
      'valorEsperado': expected,
    }),
  );
  static String _parse(Map<String, dynamic> json) {
    final response = ApiResponse<String>.fromJson(
      json,
      (value) => (value as Map<String, dynamic>)['condiciones'] as String,
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  void dispose() => _client.dispose();
}
