import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/features/mantenimientos/dtos/mantenimiento_estado_dto.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento_dto.dart';

class MantenimientoService {
  MantenimientoService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<Mantenimiento>> getAll({String? search, int? idVehiculo}) async =>
      (await getListado(
        search: search,
        idVehiculo: idVehiculo,
      )).map((x) => x.mantenimiento).toList();

  Future<MantenimientoEstadoDto> getEstado(int id) async =>
      _parseEstado(await _client.getJson('${ApiConfig.mantenimientos}/$id'));

  Future<MantenimientoEstadoDto> completar(int id, String rowVersion) async =>
      _parseEstado(
        await _client.patchJson(
          '${ApiConfig.mantenimientos}/$id/completar',
          body: {'rowVersion': rowVersion},
        ),
      );

  static MantenimientoEstadoDto _parseEstado(Map<String, dynamic> json) {
    final response = ApiResponse<MantenimientoEstadoDto>.fromJson(
      json,
      (value) => MantenimientoEstadoDto.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  Future<List<MantenimientoListadoDto>> getListado({
    String? search,
    int? idVehiculo,
  }) async {
    final uri = Uri.parse(ApiConfig.mantenimientos).replace(
      queryParameters: {
        'pageSize': '100',
        if (idVehiculo != null) 'idVehiculo': '$idVehiculo',
        if (search?.trim().isNotEmpty == true) 'search': search!.trim(),
      },
    );
    final response = ApiResponse<List<MantenimientoListadoDto>>.fromJson(
      await _client.getJson(uri.toString()),
      (value) => (value as List<dynamic>)
          .map(
            (item) =>
                MantenimientoListadoDto.fromJson(item as Map<String, dynamic>),
          )
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

  Future<Mantenimiento> create(MantenimientoDto dto) async {
    final json = await _client.postJson(ApiConfig.mantenimientos, dto.toJson());

    return _parse(json);
  }

  Future<Mantenimiento> update(int id, MantenimientoDto dto) async {
    final json = await _client.putJson(
      '${ApiConfig.mantenimientos}/$id',
      dto.toJson(),
    );

    return _parse(json);
  }

  Future<List<MantenimientoCatalogo>> _catalogo(String path) async {
    final response = ApiResponse<List<MantenimientoCatalogo>>.fromJson(
      await _client.getJson('${ApiConfig.mantenimientos}/$path'),
      (value) => (value as List<dynamic>)
          .map(
            (item) =>
                MantenimientoCatalogo.fromJson(item as Map<String, dynamic>),
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

  Future<void> eliminar(int id) async {
    final response = ApiResponse<Object?>.fromJson(
      await _client.deleteJson('${ApiConfig.mantenimientos}/$id'),
      (value) => value,
    );
    if (!response.success) throw ApiException(message: response.message);
  }

  void dispose() => _client.dispose();
}
