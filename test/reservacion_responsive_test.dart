import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/widgets/reservacion_card.dart';

void main() {
  for (final width in [320.0, 390.0, 1024.0]) {
    testWidgets('Tarjeta legible y editable a $width px', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var edited = false;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ListView(children: [
        ReservacionCard(
          reservacion: Reservacion(idReservacion: 123456, idVehiculo: 1,
            vehiculoDescripcion: 'Hyundai Sonata LF (AA41516) vehículo de prueba',
            idCliente: 1, clienteNombre: 'Manuel Tavarez con nombre comercial largo',
            idEstado: 1, estadoCodigo: 'PENDIENTE', estadoNombre: 'Pendiente de confirmación',
            fechaInicio: DateTime(2026, 10, 17), fechaFin: DateTime(2026, 10, 20),
            observacion: '', fechaCreacion: DateTime(2026, 10, 17)),
          onEdit: () => edited = true, onConfirm: () {}, onCancel: () {}),
      ]))));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Manuel Tavarez con nombre comercial largo'));
      expect(edited, isTrue);
    });
  }
}
