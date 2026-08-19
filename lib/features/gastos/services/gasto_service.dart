import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import '../models/gasto.dart';
import '../models/gasto_catalog_option.dart';
import '../models/gasto_dto.dart';
import '../models/gasto_page_result.dart';
import '../models/gasto_summary.dart';

class GastoService {
  GastoService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<GastoPageResult> getAll({
    int page = 1,
    int pageSize = 20,
    String search = '',
  }) async {
    final uri = Uri.parse(ApiConfig.gastos).replace(
      queryParameters: {
        'pageNumber': '$page',
        'pageSize': '$pageSize',
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final result = await _client.getJsonResult(uri.toString());
    final response = ApiResponse<List<Gasto>>.fromJson(
      result.json,
      (value) => (value as List)
          .map((e) => Gasto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (!response.success) throw ApiException(message: response.message);
    final items = response.data ?? const <Gasto>[];
    return GastoPageResult(
      items: items,
      total:
          int.tryParse(result.headers['x-total-count'] ?? '') ?? items.length,
      page: int.tryParse(result.headers['x-page-number'] ?? '') ?? page,
      pageSize: int.tryParse(result.headers['x-page-size'] ?? '') ?? pageSize,
    );
  }

  Future<Gasto> getById(int id) =>
      _parse(_client.getJson('${ApiConfig.gastos}/$id'));
  Future<Gasto> create(GastoDto dto) =>
      _parse(_client.postJson(ApiConfig.gastos, dto.toJson()));
  Future<Gasto> update(int id, GastoDto dto) =>
      _parse(_client.putJson('${ApiConfig.gastos}/$id', dto.toJson()));

  Future<void> delete(int id) async {
    final response = ApiResponse<Object?>.fromJson(
      await _client.deleteJson('${ApiConfig.gastos}/$id'),
      (v) => v,
    );
    if (!response.success) throw ApiException(message: response.message);
  }

  Future<GastoSummary> summary() async {
    final response = ApiResponse<GastoSummary>.fromJson(
      await _client.getJson('${ApiConfig.gastos}/resumen'),
      (value) => GastoSummary.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  Future<List<GastoCatalogOption>> tipos() async {
    final items = await _catalog(
      '${ApiConfig.catalogs}/tipos?categoria=GASTOS',
    );
    return items
        .where((item) {
          final code = item.code.toUpperCase();
          return !code.contains('MANTEN') && !code.contains('REPAR');
        })
        .toList(growable: false);
  }

  Future<List<GastoCatalogOption>> monedas() =>
      _catalog('${ApiConfig.catalogs}/monedas');

  Future<List<GastoCatalogOption>> vehiculos() async {
    final response = ApiResponse<List<GastoCatalogOption>>.fromJson(
      await _client.getJson(ApiConfig.vehiculos),
      (value) => (value as List).map((raw) {
        final item = raw as Map<String, dynamic>;
        return GastoCatalogOption(
          id: item['idVehiculo'] as int,
          name: '${item['marca']} ${item['modelo']} · ${item['placa']}',
        );
      }).toList(),
    );
    if (!response.success) throw ApiException(message: response.message);
    return response.data ?? const [];
  }

  Future<List<GastoCatalogOption>> _catalog(String url) async {
    final response = ApiResponse<List<GastoCatalogOption>>.fromJson(
      await _client.getJson(url),
      (value) => (value as List).map((raw) {
        final item = raw as Map<String, dynamic>;
        return GastoCatalogOption(
          id: item['id'] as int,
          name: item['name'] as String? ?? item['nombre'] as String? ?? '',
          code: item['code'] as String? ?? '',
        );
      }).toList(),
    );
    if (!response.success) throw ApiException(message: response.message);
    return response.data ?? const [];
  }

  Future<Gasto> _parse(Future<Map<String, dynamic>> request) async {
    final response = ApiResponse<Gasto>.fromJson(
      await request,
      (value) => Gasto.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  void dispose() => _client.dispose();
}
