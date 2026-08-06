import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento_dto.dart';

class MantenimientoService {
  MantenimientoService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<Mantenimiento>> getAll({String? search}) async {
    final uri = Uri.parse(ApiConfig.mantenimientos).replace(
      queryParameters: {
        'pageSize': '100',
        if (search?.trim().isNotEmpty == true) 'search': search!.trim(),
      },
    );
    final response = ApiResponse<List<Mantenimiento>>.fromJson(
      await _client.getJson(uri.toString()),
      (value) => (value as List<dynamic>)
          .map((item) => Mantenimiento.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
    if (!response.success) throw ApiException(message: response.message);
    return response.data ?? const [];
  }

  Future<MantenimientoResumen> resumen() async => _parseResumen(
    await _client.getJson('${ApiConfig.mantenimientos}/resumen'),
  );

  Future<List<MantenimientoCatalogo>> tipos() => _catalogo('tipos');
  Future<List<MantenimientoCatalogo>> vehiculos() => _catalogo('vehiculos');

  Future<Mantenimiento> create(MantenimientoDto dto) =>
      _parse(await _client.postJson(ApiConfig.mantenimientos, dto.toJson()));

  Future<Mantenimiento> update(int id, MantenimientoDto dto) => _parse(
    await _client.putJson('${ApiConfig.mantenimientos}/$id', dto.toJson()),
  );

  Future<List<MantenimientoCatalogo>> _catalogo(String path) async {
    final response = ApiResponse<List<MantenimientoCatalogo>>.fromJson(
      await _client.getJson('${ApiConfig.mantenimientos}/$path'),
      (value) => (value as List<dynamic>)
          .map(
            (item) => MantenimientoCatalogo.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
    );
    if (!response.success) throw ApiException(message: response.message);
    return response.data ?? const [];
  }

  static Mantenimiento _parse(Map<String, dynamic> json) {
    final response = ApiResponse<Mantenimiento>.fromJson(
      json,
      (value) => Mantenimiento.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  static MantenimientoResumen _parseResumen(Map<String, dynamic> json) {
    final response = ApiResponse<MantenimientoResumen>.fromJson(
      json,
      (value) => MantenimientoResumen.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  void dispose() => _client.dispose();
}
