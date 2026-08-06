import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import '../models/configuracion_catalogo.dart';

class ConfiguracionService {
  ConfiguracionService({ApiClient? apiClient})
    : _api = apiClient ?? ApiClient();
  final ApiClient _api;

  Future<List<ConfiguracionCatalogoDefinition>> getDefinitions() async {
    final json = await _api.getJson(
      '${ApiConfig.baseUrl}/api/configuracion/catalogos',
    );
    final data = json['data'] as List<dynamic>? ?? const [];
    return [
      ...data.map(
        (item) => ConfiguracionCatalogoDefinition.fromJson(
          item as Map<String, dynamic>,
        ),
      ),
      const ConfiguracionCatalogoDefinition(
        key: 'accesorios',
        nombre: 'Accesorios',
        esGlobal: false,
        esAccesorio: true,
      ),
    ];
  }

  Future<List<ConfiguracionCatalogoItem>> getItems(
    ConfiguracionCatalogoDefinition definition, {
    required bool incluirInactivos,
  }) async {
    final url = definition.esAccesorio
        ? '${ApiConfig.accesorios}?incluirInactivos=$incluirInactivos'
        : '${ApiConfig.baseUrl}/api/configuracion/catalogos/${definition.key}?incluirInactivos=$incluirInactivos';
    final json = await _api.getJson(url);
    final data = json['data'] as List<dynamic>? ?? const [];
    return data
        .map(
          (item) => definition.esAccesorio
              ? ConfiguracionCatalogoItem.fromAccesorio(
                  item as Map<String, dynamic>,
                )
              : ConfiguracionCatalogoItem.fromJson(
                  item as Map<String, dynamic>,
                ),
        )
        .toList(growable: false);
  }

  Future<void> create(
    ConfiguracionCatalogoDefinition definition,
    ConfiguracionCatalogoDraft draft,
  ) async {
    final url = definition.esAccesorio
        ? ApiConfig.accesorios
        : '${ApiConfig.baseUrl}/api/configuracion/catalogos/${definition.key}';
    await _api.postJson(url, draft.toJson(accesorio: definition.esAccesorio));
  }

  Future<void> update(
    ConfiguracionCatalogoDefinition definition,
    int id,
    ConfiguracionCatalogoDraft draft,
  ) async {
    final url = definition.esAccesorio
        ? '${ApiConfig.accesorios}/$id'
        : '${ApiConfig.baseUrl}/api/configuracion/catalogos/${definition.key}/$id';
    await _api.putJson(url, draft.toJson(accesorio: definition.esAccesorio));
  }

  Future<void> setActive(
    ConfiguracionCatalogoDefinition definition,
    int id,
    bool active,
  ) async {
    final base = definition.esAccesorio
        ? '${ApiConfig.accesorios}/$id'
        : '${ApiConfig.baseUrl}/api/configuracion/catalogos/${definition.key}/$id';
    if (active) {
      await _api.patchJson('$base/restaurar');
    } else {
      await _api.deleteJson(base);
    }
  }
}
