import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/rentas/models/renta.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_dto.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_page_result.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_summary.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_entrega.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_filters.dart';

class RentaService {
  RentaService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<RentaPageResult> getAll({
    RentaListScope scope = RentaListScope.active,
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
    int? idEstado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final path = switch (scope) {
      RentaListScope.active => 'activas',
      RentaListScope.history => 'historicas',
    };
    final uri = Uri.parse('${ApiConfig.rentas}/$path').replace(
      queryParameters: {
        'pageNumber': '$pageNumber',
        'pageSize': '$pageSize',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (idEstado != null) 'idEstado': '$idEstado',
        if (fechaDesde != null)
          'fechaDesde': fechaDesde.toUtc().toIso8601String(),
        if (fechaHasta != null)
          'fechaHasta': fechaHasta.toUtc().toIso8601String(),
      },
    );
    final result = await _apiClient.getJsonResult(uri.toString());
    final response = ApiResponse<List<Renta>>.fromJson(
      result.json,
      (value) => (value as List<dynamic>)
          .map((item) => Renta.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
    _ensureSuccess(response.success, response.message);
    final items = response.data ?? const <Renta>[];
    return RentaPageResult(
      items: items,
      totalCount: _header(result.headers, 'x-total-count', items.length),
      pageNumber: _header(result.headers, 'x-page-number', pageNumber),
      pageSize: _header(result.headers, 'x-page-size', pageSize),
    );
  }

  Future<Renta> getById(int id) =>
      _parseRenta(_apiClient.getJson('${ApiConfig.rentas}/$id'));

  Future<RentaEntrega> getEntrega(int id) async {
    final response = ApiResponse<RentaEntrega>.fromJson(
      await _apiClient.getJson('${ApiConfig.rentas}/$id/entrega'),
      (value) => RentaEntrega.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: _message(response.message));
    }
    return response.data!;
  }

  Future<Renta> create(RentaCreateDto dto) =>
      _parseRenta(_apiClient.postJson(ApiConfig.rentas, dto.toJson()));

  Future<Renta> createFromReservation(
    int reservationId,
    ConvertirReservacionRentaDto dto,
  ) => _parseRenta(
    _apiClient.postJson(
      '${ApiConfig.rentas}/desde-reservacion/$reservationId',
      dto.toJson(),
    ),
  );

  Future<Renta> update(int id, RentaUpdateDto dto) =>
      _parseRenta(_apiClient.putJson('${ApiConfig.rentas}/$id', dto.toJson()));

  Future<Renta> complete(int id, FinalizarRentaDto dto) => _parseRenta(
    _apiClient.patchJson(
      '${ApiConfig.rentas}/$id/finalizar',
      body: dto.toJson(),
    ),
  );

  Future<Renta> cancel(int id) =>
      _parseRenta(_apiClient.patchJson('${ApiConfig.rentas}/$id/cancelar'));

  Future<RentaSummary> getSummary(int id) async {
    final response = ApiResponse<RentaSummary>.fromJson(
      await _apiClient.getJson('${ApiConfig.rentas}/$id/resumen'),
      (value) => RentaSummary.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: _message(response.message));
    }
    return response.data!;
  }

  Future<Renta> _parseRenta(Future<Map<String, dynamic>> request) async {
    final response = ApiResponse<Renta>.fromJson(
      await request,
      (value) => Renta.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: _message(response.message));
    }
    return response.data!;
  }

  static void _ensureSuccess(bool success, String message) {
    if (!success) throw ApiException(message: _message(message));
  }

  static String _message(String value) => value.trim().isEmpty
      ? 'La API no devolvió la información esperada.'
      : value;

  static int _header(Map<String, String> headers, String key, int fallback) =>
      int.tryParse(headers[key] ?? '') ?? fallback;

  void dispose() => _apiClient.dispose();
}
