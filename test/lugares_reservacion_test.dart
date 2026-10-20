import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion_dto.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_dto.dart';

void main() {
  test('DTO conserva omisión y permite borrado explícito', () {
    final original = ReservacionDto(idVehiculo: 1, idCliente: 2,
      fechaInicio: DateTime(2026), fechaFin: DateTime(2027));
    expect(original.toJson().containsKey('lugarEntrega'), isFalse);
    final edited = ReservacionDto(idVehiculo: 1, idCliente: 2,
      fechaInicio: DateTime(2026), fechaFin: DateTime(2027),
      lugarEntrega: ' Aeropuerto ', lugarRecepcion: '');
    expect(edited.toJson()['lugarEntrega'], 'Aeropuerto');
    expect(edited.toJson()['lugarRecepcion'], '');
  });
  test('Conversión envía lugares ajustados', () {
    const dto = ConvertirReservacionRentaDto(impuestos: 0, descuentos: 0,
      deposito: 0, tasaCambioAplicada: 1, lugarEntrega: ' Hotel ', lugarRecepcion: 'Oficina');
    expect(dto.toJson()['lugarEntrega'], 'Hotel');
    expect(dto.toJson()['lugarRecepcion'], 'Oficina');
  });
  test('Reservas históricas admiten campos ausentes y nuevas leen lugares', () {
    final json = <String, dynamic>{'idReservacion': 1, 'idVehiculo': 2,
      'idCliente': 3, 'idEstado': 4, 'fechaInicio': '2026-10-10T12:00:00Z',
      'fechaFin': '2026-10-12T12:00:00Z', 'fechaCreacion': '2026-10-09T12:00:00Z'};
    expect(Reservacion.fromJson(json).lugarEntrega, isNull);
    expect(Reservacion.fromJson({...json, 'lugarEntrega': 'Hotel'}).lugarEntrega, 'Hotel');
  });
}
