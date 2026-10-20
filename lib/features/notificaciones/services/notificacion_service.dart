import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/notificaciones/dtos/notificacion_resultado_dto.dart';

class NotificacionService {
  NotificacionService({ApiClient? apiClient})
    : _client = apiClient ?? ApiClient();
  final ApiClient _client;
  Future<List<NotificacionResultadoDto>> contrato(
    int id, {
    required bool correo,
    required bool whatsapp,
    required bool cliente,
    required bool empresa,
    required bool simular,
  }) async {
    final response = ApiResponse<List<NotificacionResultadoDto>>.fromJson(
      await _client.postJson(
        '${ApiConfig.baseUrl}/api/notificaciones/rentas/$id/contrato',
        {
          'correo': correo,
          'whatsApp': whatsapp,
          'cliente': cliente,
          'empresa': empresa,
          'simular': simular,
        },
      ),
      (value) => (value as List<dynamic>)
          .map(
            (item) =>
                NotificacionResultadoDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
    if (!response.success) throw ApiException(message: response.message);
    return response.data ?? [];
  }

  void dispose() => _client.dispose();
}
