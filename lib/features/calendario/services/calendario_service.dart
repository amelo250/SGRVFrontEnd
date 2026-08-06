import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/calendario/models/calendario_evento.dart';

class CalendarioService {
  CalendarioService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<CalendarioResumen> obtener({
    required DateTime desde,
    required DateTime hasta,
    String? tipo,
    int? idVehiculo,
  }) async {
    final uri = Uri.parse(ApiConfig.calendario).replace(
      queryParameters: {
        'fechaDesde': desde.toUtc().toIso8601String(),
        'fechaHasta': hasta.toUtc().toIso8601String(),
        if (tipo != null && tipo.isNotEmpty) 'tipo': tipo,
        if (idVehiculo != null) 'idVehiculo': '$idVehiculo',
      },
    );
    final response = ApiResponse<CalendarioResumen>.fromJson(
      await _apiClient.getJson(uri.toString()),
      (value) => CalendarioResumen.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message.isEmpty
            ? 'La API no devolvió el calendario esperado.'
            : response.message,
      );
    }
    return response.data!;
  }

  void dispose() => _apiClient.dispose();
}
