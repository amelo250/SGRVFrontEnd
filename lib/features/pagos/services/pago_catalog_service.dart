import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_catalog_option.dart';

class PagoCatalogService {
  PagoCatalogService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<PagoCatalogOption>> getPaymentMethods() =>
      _getOptions('${ApiConfig.catalogs}/metodos-pago');

  Future<List<PagoCurrencyOption>> getCurrencies() async {
    final response = ApiResponse<List<PagoCurrencyOption>>.fromJson(
      await _apiClient.getJson('${ApiConfig.catalogs}/monedas'),
      (value) => (value as List<dynamic>)
          .map(
            (item) => PagoCurrencyOption.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
    return response.data ?? const <PagoCurrencyOption>[];
  }

  Future<List<PagoCatalogOption>> _getOptions(String url) async {
    final response = ApiResponse<List<PagoCatalogOption>>.fromJson(
      await _apiClient.getJson(url),
      (value) => (value as List<dynamic>)
          .map(
            (item) => PagoCatalogOption.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
    return response.data ?? const <PagoCatalogOption>[];
  }

  void dispose() => _apiClient.dispose();
}
