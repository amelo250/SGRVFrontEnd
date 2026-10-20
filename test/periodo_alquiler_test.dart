import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/utils/periodo_alquiler_fechas.dart';
import 'package:sgrv_frontend/features/configuracion/services/configuracion_alquiler_service.dart';
import 'package:sgrv_frontend/features/rentas/dtos/politica_renta_dto.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  test(
    'configuración transmite valor esperado y no una empresa elegida',
    () async {
      final service = ConfiguracionAlquilerService(
        client: ApiClient(
          client: MockClient((request) async {
            expect(request.method, 'PUT');
            expect(request.url.path, '/api/configuracion/empresa/alquiler');
            expect(jsonDecode(request.body), {
              'capturarHorasPeriodoAlquiler': false,
              'valorEsperado': true,
            });
            return http.Response(
              '{"success":true,"data":{"capturarHorasPeriodoAlquiler":false}}',
              200,
            );
          }),
        ),
      );
      addTearDown(service.dispose);
      expect(await service.save(false, true), isFalse);
    },
  );
  test('conflicto no se trata como guardado', () async {
    final service = ConfiguracionAlquilerService(
      client: ApiClient(
        client: MockClient(
          (_) async =>
              http.Response('{"success":false,"message":"Recarga"}', 409),
        ),
      ),
    );
    addTearDown(service.dispose);
    await expectLater(
      service.save(false, true),
      throwsA(isA<ApiException>().having((x) => x.statusCode, 'status', 409)),
    );
  });
  test('días inclusivos y presentación no muestran horas técnicas', () {
    final start = PeriodoAlquilerFechas.desdeDia(DateTime(2027, 1, 6));
    final end = PeriodoAlquilerFechas.desdeDia(DateTime(2027, 1, 8), fin: true);
    expect(start.toUtc(), DateTime.utc(2027, 1, 6, 4));
    expect(const PoliticaRentaDto(minimoDias: 3).dias(start, end), 3);
    expect(
      PeriodoAlquilerFechas.formato(end, true),
      '08/01/2027 · Sin hora definida',
    );
    expect(
      PeriodoAlquilerFechas.formato(start, false),
      isNot(contains('Sin hora')),
    );
  });
  test(
    'snapshot antiguo conserva horas y servidor nuevo conserva modo sin hora',
    () {
      final json = <String, dynamic>{
        'idReservacion': 1,
        'idVehiculo': 1,
        'idCliente': 1,
        'idEstado': 1,
        'fechaInicio': '2027-01-06T04:00:00Z',
        'fechaFin': '2027-01-09T03:59:59Z',
        'fechaCreacion': '2027-01-01T04:00:00Z',
      };
      expect(Reservacion.fromJson(json).periodoSinHora, isFalse);
      expect(
        Reservacion.fromJson({...json, 'periodoSinHora': true}).periodoSinHora,
        isTrue,
      );
      expect(
        PoliticaRentaDto.fromJson({
          'minimoDias': 3,
        }).capturarHorasPeriodoAlquiler,
        isTrue,
      );
    },
  );
}
