import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo_dto.dart';

class VehiculoService {
  VehiculoService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Vehiculo>> getVehiculos({bool incluirInactivos = false}) async {
    final json = await _apiClient.getJson(
      '${ApiConfig.vehiculos}?incluirInactivos=$incluirInactivos',
    );
    final response = ApiResponse<List<Vehiculo>>.fromJson(
      json,
      (value) => (value as List<dynamic>)
          .map((item) => Vehiculo.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
    return response.data ?? const [];
  }

  Future<Vehiculo> crear(VehiculoDto dto) async {
    return _parseVehiculo(
      await _apiClient.postJson(ApiConfig.vehiculos, dto.toJson()),
    );
  }

  Future<Vehiculo> actualizar(int id, VehiculoDto dto) async {
    return _parseVehiculo(
      await _apiClient.putJson('${ApiConfig.vehiculos}/$id', dto.toJson()),
    );
  }

  Future<Vehiculo> cambiarEstado(int id, int idEstado) async {
    return _parseVehiculo(
      await _apiClient.putJson(
        '${ApiConfig.vehiculos}/$id/estado',
        VehiculoEstadoUpdateDto(idEstado).toJson(),
      ),
    );
  }

  Future<void> desactivar(int id) async {
    await _apiClient.deleteJson('${ApiConfig.vehiculos}/$id');
  }

  Vehiculo _parseVehiculo(Map<String, dynamic> json) {
    final response = ApiResponse<Vehiculo>.fromJson(
      json,
      (value) => Vehiculo.fromJson(value as Map<String, dynamic>),
    );
    final vehiculo = response.data;
    if (vehiculo == null) {
      throw const ApiException(
        message: 'La API no devolvió el vehículo esperado.',
      );
    }
    return vehiculo;
  }
}
