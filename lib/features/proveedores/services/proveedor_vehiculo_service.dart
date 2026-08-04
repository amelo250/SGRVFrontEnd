import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/proveedores/models/proveedor_vehiculo.dart';
import 'package:sgrv_frontend/features/proveedores/models/proveedor_vehiculo_dto.dart';

class ProveedorVehiculoService {
  ProveedorVehiculoService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ProveedorVehiculo>> obtenerTodos({
    bool incluirInactivos = false,
    String? busqueda,
  }) async {
    final query = <String, String>{
      'incluirInactivos': incluirInactivos.toString(),
      if (busqueda != null && busqueda.trim().isNotEmpty)
        'search': busqueda.trim(),
    };
    final uri = Uri.parse(
      ApiConfig.proveedoresVehiculos,
    ).replace(queryParameters: query);
    final json = await _apiClient.getJson(uri.toString());
    final response = ApiResponse<List<ProveedorVehiculo>>.fromJson(
      json,
      (value) => (value as List<dynamic>)
          .map(
            (item) => ProveedorVehiculo.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
    return response.data ?? const [];
  }

  Future<ProveedorVehiculo> crear(ProveedorVehiculoDto dto) async {
    return _parse(
      await _apiClient.postJson(ApiConfig.proveedoresVehiculos, dto.toJson()),
    );
  }

  Future<ProveedorVehiculo> actualizar(int id, ProveedorVehiculoDto dto) async {
    return _parse(
      await _apiClient.putJson(
        '${ApiConfig.proveedoresVehiculos}/$id',
        dto.toJson(),
      ),
    );
  }

  Future<void> desactivar(int id) async {
    await _apiClient.deleteJson('${ApiConfig.proveedoresVehiculos}/$id');
  }

  ProveedorVehiculo _parse(Map<String, dynamic> json) {
    final response = ApiResponse<ProveedorVehiculo>.fromJson(
      json,
      (value) => ProveedorVehiculo.fromJson(value as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw const ApiException(
        message: 'La API no devolvió el proveedor esperado.',
      );
    }
    return response.data!;
  }
}
