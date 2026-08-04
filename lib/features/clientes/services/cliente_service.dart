import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente_dto.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente_page_result.dart';

class ClienteService {
  ClienteService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ClientePageResult> getClientes({
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
    bool incluirInactivos = false,
  }) async {
    final uri = Uri.parse(ApiConfig.clientes).replace(
      queryParameters: {
        'pageNumber': '$pageNumber',
        'pageSize': '$pageSize',
        'incluirInactivos': '$incluirInactivos',
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
      },
    );
    final result = await _apiClient.getJsonResult(uri.toString());
    final response = ApiResponse<List<Cliente>>.fromJson(
      result.json,
      (value) => (value as List<dynamic>)
          .map((item) => Cliente.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
    if (!response.success) {
      throw ApiException(message: response.message);
    }
    final items = response.data ?? const <Cliente>[];
    return ClientePageResult(
      items: items,
      totalCount: _header(result.headers, 'x-total-count', items.length),
      pageNumber: _header(result.headers, 'x-page-number', pageNumber),
      pageSize: _header(result.headers, 'x-page-size', pageSize),
    );
  }

  Future<Cliente> crear(ClienteDto dto) =>
      _parse(_apiClient.postJson(ApiConfig.clientes, dto.toJson()));

  Future<Cliente> actualizar(int id, ClienteDto dto) => _parse(
    _apiClient.putJson('${ApiConfig.clientes}/$id', dto.toJson()),
  );

  Future<void> desactivar(int id) async {
    await _apiClient.deleteJson('${ApiConfig.clientes}/$id');
  }

  Future<Cliente> restaurar(int id) => _parse(
    _apiClient.patchJson('${ApiConfig.clientes}/$id/restaurar'),
  );

  Future<Cliente> _parse(Future<Map<String, dynamic>> request) async {
    final response = ApiResponse<Cliente>.fromJson(
      await request,
      (value) => Cliente.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message.isEmpty
            ? 'La API no devolvió el cliente esperado.'
            : response.message,
      );
    }
    return response.data!;
  }

  static int _header(
    Map<String, String> headers,
    String key,
    int fallback,
  ) => int.tryParse(headers[key] ?? '') ?? fallback;
}
