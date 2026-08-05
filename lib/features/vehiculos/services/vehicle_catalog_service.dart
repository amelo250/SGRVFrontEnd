import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehicle_catalog_option.dart';

class VehicleCatalogService {
  VehicleCatalogService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<VehicleCatalogOption>> getTypes() =>
      _getOptions('${ApiConfig.catalogs}/tipos?categoria=VEHICULOS');

  Future<List<VehicleCatalogOption>> getFuels() =>
      _getOptions('${ApiConfig.catalogs}/combustibles');

  Future<List<VehicleCatalogOption>> getTransmissions() =>
      _getOptions('${ApiConfig.catalogs}/transmisiones');

  Future<List<CurrencyCatalogOption>> getCurrencies() async {
    final response = ApiResponse<List<CurrencyCatalogOption>>.fromJson(
      await _apiClient.getJson('${ApiConfig.catalogs}/monedas'),
      (value) => (value as List<dynamic>)
          .map(
            (item) =>
                CurrencyCatalogOption.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
    return response.data ?? const <CurrencyCatalogOption>[];
  }

  Future<List<VehicleCatalogOption>> _getOptions(String url) async {
    final response = ApiResponse<List<VehicleCatalogOption>>.fromJson(
      await _apiClient.getJson(url),
      (value) => (value as List<dynamic>)
          .map(
            (item) =>
                VehicleCatalogOption.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
    return response.data ?? const <VehicleCatalogOption>[];
  }

  void dispose() => _apiClient.dispose();
}
