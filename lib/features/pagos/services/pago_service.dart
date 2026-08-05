import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/pagos/models/pago.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_dto.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_page_result.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_summary.dart';

class PagoService {
  PagoService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PagoPageResult> getAll({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
    int? idRenta,
    bool incluirInactivos = false,
  }) async {
    final uri = Uri.parse(ApiConfig.pagos).replace(
      queryParameters: {
        'pageNumber': '$pageNumber',
        'pageSize': '$pageSize',
        'incluirInactivos': '$incluirInactivos',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (idRenta != null) 'idRenta': '$idRenta',
      },
    );
    final result = await _apiClient.getJsonResult(uri.toString());
    final response = ApiResponse<List<Pago>>.fromJson(
      result.json,
      (value) => (value as List<dynamic>)
          .map((item) => Pago.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
    _ensure(response.success, response.message);
    final items = response.data ?? const <Pago>[];
    return PagoPageResult(
      items: items,
      totalCount: _header(result.headers, 'x-total-count', items.length),
      pageNumber: _header(result.headers, 'x-page-number', pageNumber),
      pageSize: _header(result.headers, 'x-page-size', pageSize),
    );
  }

  Future<Pago> getById(int id) =>
      _parsePago(_apiClient.getJson('${ApiConfig.pagos}/$id'));

  Future<Pago> create(PagoCreateDto dto) =>
      _parsePago(_apiClient.postJson(ApiConfig.pagos, dto.toJson()));

  Future<void> voidPayment(int id) async {
    final response = ApiResponse<Object?>.fromJson(
      await _apiClient.deleteJson('${ApiConfig.pagos}/$id'),
      (value) => value,
    );
    _ensure(response.success, response.message);
  }

  Future<Pago> restore(int id) =>
      _parsePago(_apiClient.patchJson('${ApiConfig.pagos}/$id/restaurar'));

  Future<PagoSummary> getSummary(int idRenta) async {
    final response = ApiResponse<PagoSummary>.fromJson(
      await _apiClient.getJson('${ApiConfig.pagos}/renta/$idRenta/resumen'),
      (value) => PagoSummary.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: _message(response.message));
    }
    return response.data!;
  }

  Future<Pago> _parsePago(Future<Map<String, dynamic>> request) async {
    final response = ApiResponse<Pago>.fromJson(
      await request,
      (value) => Pago.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: _message(response.message));
    }
    return response.data!;
  }

  static void _ensure(bool success, String message) {
    if (!success) throw ApiException(message: _message(message));
  }

  static String _message(String value) => value.trim().isEmpty
      ? 'La API no devolvió la información esperada.'
      : value;

  static int _header(Map<String, String> headers, String key, int fallback) =>
      int.tryParse(headers[key] ?? '') ?? fallback;

  void dispose() => _apiClient.dispose();
}
