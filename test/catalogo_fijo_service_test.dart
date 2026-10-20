import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/reservaciones/services/reservacion_service.dart';

class CatalogApi extends ApiClient {
  String? requested;
  bool enabled = true;
  @override
  Future<Map<String, dynamic>> getJson(String url) async {
    requested = url;
    return enabled
        ? {'success': true, 'data': {'url': 'https://example.test/reservar/empresa-a'}}
        : {'success': false, 'message': 'El catálogo no está disponible.'};
  }
}

void main() {
  test('consulta el enlace de la empresa autenticada sin enviar IdEmpresa', () async {
    final api = CatalogApi();
    final service = ReservacionService(apiClient: api);
    addTearDown(service.dispose);
    expect(await service.obtenerCatalogoFijo(), 'https://example.test/reservar/empresa-a');
    final uri = Uri.parse(api.requested!);
    expect(uri.path, endsWith('/api/reservaciones-publicas/catalogo-fijo'));
    expect(uri.query, isEmpty);
  });
  test('catálogo no configurado produce error en lugar de enlace vacío', () async {
    final service = ReservacionService(apiClient: CatalogApi()..enabled = false);
    addTearDown(service.dispose);
    await expectLater(service.obtenerCatalogoFijo(), throwsA(isA<ApiException>()));
  });
}
