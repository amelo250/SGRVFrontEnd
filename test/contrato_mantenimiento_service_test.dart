import 'dart:typed_data';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_entrega.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_entrega_document.dart';
import 'package:sgrv_frontend/features/rentas/services/renta_entrega_pdf_service.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';
import 'package:sgrv_frontend/features/configuracion/services/condiciones_contrato_service.dart';
import 'package:sgrv_frontend/features/mantenimientos/services/mantenimiento_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  test('eliminar transmite JWT y no permite escoger empresa', () async {
    await TokenStorage.saveToken('test-token');
    final service = MantenimientoService(
      client: ApiClient(
        client: MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(request.url.path, '/api/mantenimientos/12');
          expect(request.url.queryParameters, isEmpty);
          expect(request.headers['Authorization'], 'Bearer test-token');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'idMantenimiento': 12, 'activo': false},
            }),
            200,
          );
        }),
      ),
    );
    addTearDown(service.dispose);
    await service.eliminar(12);
  });
  test(
    'condiciones conserva texto y valor esperado sin empresa manipulable',
    () async {
      final service = CondicionesContratoService(
        client: ApiClient(
          client: MockClient((request) async {
            expect(request.url.path, '/api/configuracion/empresa/contrato');
            expect(jsonDecode(request.body), {
              'condiciones': 'Nuevas condiciones',
              'valorEsperado': 'Anterior',
            });
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {'condiciones': 'Nuevas condiciones'},
              }),
              200,
            );
          }),
        ),
      );
      addTearDown(service.dispose);
      expect(
        await service.save('Nuevas condiciones', 'Anterior'),
        'Nuevas condiciones',
      );
    },
  );
  test('conflicto de condiciones no se interpreta como guardado', () async {
    final service = CondicionesContratoService(
      client: ApiClient(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'success': false,
              'message': 'Recarga antes de guardar.',
            }),
            409,
          ),
        ),
      ),
    );
    addTearDown(service.dispose);
    await expectLater(
      service.save('Nuevo', 'Viejo'),
      throwsA(isA<ApiException>()),
    );
  });
  for (final withLogo in [false, true]) {
    test('PDF genera condiciones extensas con logo=$withLogo', () async {
      await initializeDateFormatting('es_DO');
      final image = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4//8/AAX+Av4N70a4AAAAAElFTkSuQmCC',
      );
      var logoLoaded = false;
      final api = ApiClient(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/logo/contenido')) {
            logoLoaded = true;
            return http.Response.bytes(
              image,
              200,
              headers: {'content-type': 'image/png'},
            );
          }
          expect(request.url.path, '/api/configuracion/empresa/contrato');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'condiciones': List.filled(
                  500,
                  'Condición personalizada.',
                ).join(' '),
              },
            }),
            200,
          );
        }),
      );
      addTearDown(api.dispose);
      final data = RentaEntrega.fromJson({
        'idRenta': 1,
        'numeroContrato': 'R-000001',
        'empresa': {
          'nombreComercial': 'Empresa de prueba',
          if (withLogo) 'logoUrl': '/api/empresas/7/logo/contenido',
        },
        'cliente': {'nombreCompleto': 'Cliente de prueba'},
        'vehiculo': <String, dynamic>{},
        'fechaInicio': '2026-10-18T12:00:00Z',
        'fechaFin': '2026-10-19T12:00:00Z',
      });
      final bytes = await RentaEntregaPdfService(client: api).generate(
        data,
        RentaEntregaDocument(
          nombreAgente: 'Agente',
          accesoriosConfirmados: {},
          firmaCliente: Uint8List.fromList(image),
          firmaAgente: Uint8List.fromList(image),
          fechaFirma: DateTime(2026, 10, 18),
          nivelCombustible: 100,
        ),
      );
      expect(ascii.decode(bytes.take(4).toList()), '%PDF');
      expect(logoLoaded, withLogo);
    });
  }
}
