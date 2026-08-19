import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import '../models/contabilidad_resumen.dart';

class ContabilidadService {
  ContabilidadService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<ContabilidadResumen> get({
    DateTime? desde,
    DateTime? hasta,
    String? tipo,
    String? categoria,
  }) async {
    String date(DateTime x) =>
        '${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse(ApiConfig.contabilidad).replace(
      queryParameters: {
        if (desde != null) 'fechaDesde': date(desde),
        if (hasta != null) 'fechaHasta': date(hasta),
        if (tipo != null && tipo != 'TODOS') 'tipo': tipo,
        if (categoria != null && categoria != 'TODAS') 'categoria': categoria,
      },
    );
    final response = ApiResponse<ContabilidadResumen>.fromJson(
      await _client.getJson(uri.toString()),
      (v) => ContabilidadResumen.fromJson(v as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  void dispose() => _client.dispose();
}
