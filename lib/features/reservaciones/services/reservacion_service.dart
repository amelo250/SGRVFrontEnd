import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion_dto.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion_page_result.dart';

class ReservacionService {
  ReservacionService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ReservacionPageResult> getAll({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
    int? idEstado,
  }) async {
    final uri = Uri.parse(ApiConfig.reservaciones).replace(
      queryParameters: {
        'pageNumber': '$pageNumber',
        'pageSize': '$pageSize',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (idEstado != null) 'idEstado': '$idEstado',
      },
    );
    final result = await _apiClient.getJsonResult(uri.toString());
    final response = ApiResponse<List<Reservacion>>.fromJson(
      result.json,
      (value) => (value as List<dynamic>)
          .map((item) => Reservacion.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
    if (!response.success) throw ApiException(message: response.message);
    final items = response.data ?? const <Reservacion>[];
    return ReservacionPageResult(
      items: items,
      totalCount: _header(result.headers, 'x-total-count', items.length),
      pageNumber: _header(result.headers, 'x-page-number', pageNumber),
      pageSize: _header(result.headers, 'x-page-size', pageSize),
    );
  }

  Future<Reservacion> create(ReservacionDto dto) =>
      _parse(_apiClient.postJson(ApiConfig.reservaciones, dto.toJson()));

  Future<Reservacion> update(int id, ReservacionDto dto) => _parse(
    _apiClient.putJson('${ApiConfig.reservaciones}/$id', dto.toJson()),
  );

  Future<Reservacion> confirm(int id) =>
      _parse(_apiClient.patchJson('${ApiConfig.reservaciones}/$id/confirmar'));

  Future<Reservacion> cancel(int id) =>
      _parse(_apiClient.patchJson('${ApiConfig.reservaciones}/$id/cancelar'));

  Future<Reservacion> _parse(Future<Map<String, dynamic>> request) async {
    final response = ApiResponse<Reservacion>.fromJson(
      await request,
      (value) => Reservacion.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message.isEmpty
            ? 'La API no devolvió la reservación esperada.'
            : response.message,
      );
    }
    return response.data!;
  }

  static int _header(Map<String, String> headers, String key, int fallback) =>
      int.tryParse(headers[key] ?? '') ?? fallback;
}
