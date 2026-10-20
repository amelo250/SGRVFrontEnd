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

  Future<String> obtenerCatalogoFijo() async {
    final endpoint = Uri.parse(ApiConfig.reservaciones).replace(
      path: '${Uri.parse(ApiConfig.reservaciones).path}-publicas/catalogo-fijo',
    );
    final response = ApiResponse<String>.fromJson(
      await _apiClient.getJson(endpoint.toString()),
      (value) => (value as Map<String, dynamic>)['url'] as String,
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  Future<String> crearEnlacePublico({
    int diasVigencia = 30,
    int? idCliente,
    bool solicitarTelefono = false,
    bool solicitarDireccion = false,
    String? monedaCodigo,
    double? pesosPorDolar,
  }) async {
    final endpoint = Uri.parse(ApiConfig.reservaciones).replace(
      path: '${Uri.parse(ApiConfig.reservaciones).path}-publicas/enlaces',
    );
    final response = ApiResponse<String>.fromJson(
      await _apiClient.postJson(endpoint.toString(), {
        'diasVigencia': diasVigencia,
        'idCliente': ?idCliente,
        'solicitarTelefono': solicitarTelefono,
        'solicitarDireccion': solicitarDireccion,
        'monedaCodigo': ?monedaCodigo,
        'pesosPorDolar': ?pesosPorDolar,
      }),
      (value) => (value as Map<String, dynamic>)['url'] as String,
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  Future<ReservacionPageResult> getAll({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
    int? idEstado,
    bool soloConvertibles = false,
    bool? historicas,
    bool soloHoy = false,
  }) async {
    final uri = Uri.parse(ApiConfig.reservaciones).replace(
      queryParameters: {
        'pageNumber': '$pageNumber',
        'pageSize': '$pageSize',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (idEstado != null) 'idEstado': '$idEstado',
        if (soloConvertibles) 'soloConvertibles': 'true',
        if (historicas != null) 'historicas': '$historicas',
        if (soloHoy) 'soloHoy': 'true',
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

  Future<List<Reservacion>> getConvertibles() async {
    final reservations = <Reservacion>[];
    var page = 1;
    while (true) {
      final result = await getAll(
        pageNumber: page,
        pageSize: 100,
        soloConvertibles: true,
      );
      reservations.addAll(result.items);
      if (result.items.isEmpty || reservations.length >= result.totalCount) {
        break;
      }
      page++;
    }
    // Una actualización concurrente entre páginas puede repetir una fila.
    return {
      for (final item in reservations) item.idReservacion: item,
    }.values.toList();
  }

  Future<Reservacion> update(int id, ReservacionDto dto) => _parse(
    _apiClient.putJson('${ApiConfig.reservaciones}/$id', dto.toJson()),
  );

  Future<Reservacion> confirm(int id) =>
      _parse(_apiClient.patchJson('${ApiConfig.reservaciones}/$id/confirmar'));

  Future<Reservacion> cancel(int id) =>
      _parse(_apiClient.patchJson('${ApiConfig.reservaciones}/$id/cancelar'));

  Future<List<Reservacion>> getUpcoming({int take = 3}) async {
    final uri = Uri.parse(ApiConfig.reservaciones).replace(
      path: '${Uri.parse(ApiConfig.reservaciones).path}/proximas',
      queryParameters: {'take': '$take'},
    );
    final response = ApiResponse<List<Reservacion>>.fromJson(
      await _apiClient.getJson(uri.toString()),
      (value) => (value as List<dynamic>)
          .map((item) => Reservacion.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
    if (!response.success) throw ApiException(message: response.message);
    return response.data ?? const <Reservacion>[];
  }

  void dispose() => _apiClient.dispose();

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
