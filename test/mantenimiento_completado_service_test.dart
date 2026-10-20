import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';
import 'package:sgrv_frontend/features/mantenimientos/dtos/mantenimiento_estado_dto.dart';
import 'package:sgrv_frontend/features/mantenimientos/services/mantenimiento_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  test(
    'cierre transmite JWT y versión, sin empresa ni usuario manipulables',
    () async {
      await TokenStorage.saveToken('test-token');
      final service = MantenimientoService(
        client: ApiClient(
          client: MockClient((request) async {
            expect(request.method, 'PATCH');
            expect(request.url.path, '/api/mantenimientos/12/completar');
            expect(request.headers['Authorization'], 'Bearer test-token');
            expect(jsonDecode(request.body), {'rowVersion': 'AAAAAAAAAAk='});
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'idMantenimiento': 12,
                  'estado': 'COMPLETADO',
                  'rowVersion': 'AAAAAAAAAAo=',
                  'fechaCompletadoUtc': '2026-10-18T12:00:00Z',
                  'idUsuarioCompletado': 3,
                  'nombreUsuarioCompletado': 'María Pérez',
                },
              }),
              200,
            );
          }),
        ),
      );
      addTearDown(service.dispose);
      final estado = await service.completar(12, 'AAAAAAAAAAk=');
      expect(estado.completado, isTrue);
      expect(estado.idUsuarioCompletado, 3);
      expect(estado.usuarioCompletadoEtiqueta, "María Pérez");
      expect(estado.fechaCompletadoUtc?.isUtc, isTrue);
    },
  );
  test(
    '409 conserva el conflicto para mostrarlo y recargar, sin éxito ficticio',
    () async {
      final service = MantenimientoService(
        client: ApiClient(
          client: MockClient(
            (_) async => http.Response(
              '{"success":false,"message":"Recarga los datos."}',
              409,
            ),
          ),
        ),
      );
      addTearDown(service.dispose);
      await expectLater(
        service.completar(12, 'AAAAAAAAAAk='),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 409)),
      );
    },
  );
  test('respuesta anterior o nula permanece sin clasificar', () {
    for (final json in [
      <String, dynamic>{'idMantenimiento': 12},
      <String, dynamic>{'idMantenimiento': 12, 'estado': null},
    ]) {
      final estado = MantenimientoEstadoDto.fromJson(json);
      expect(estado.pendiente, isFalse);
      expect(estado.completado, isFalse);
      expect(estado.etiqueta, 'Sin clasificar');
    }
  });
  test('servidor anterior o nombre vacío no vuelve a mostrar el ID', () {
    for (final nombre in [null, '', '   ']) {
      final dto = MantenimientoEstadoDto.fromJson({
        'idMantenimiento': 12,
        'idUsuarioCompletado': 987,
        'nombreUsuarioCompletado': nombre,
      });
      expect(dto.usuarioCompletadoEtiqueta, 'Usuario no disponible');
      expect(dto.idUsuarioCompletado, 987);
    }
  });
}
