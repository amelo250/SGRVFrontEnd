import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/features/rentas/widgets/reservacion_conversion_selector.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/services/reservacion_service.dart';

class FakeReservacionService extends ReservacionService {
  List<Reservacion> items = [];
  bool fail = false;
  @override
  Future<List<Reservacion>> getConvertibles() async {
    if (fail) throw Exception('Sin conexión');
    return items;
  }
}

void main() {
  late FakeReservacionService service;
  setUp(() => service = FakeReservacionService());
  tearDown(() => service.dispose());

  Future<void> show(
    WidgetTester tester, {
    ValueChanged<int?>? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: ReservacionConversionSelector(
              service: service,
              onChanged: onChanged ?? (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra vehículo y cliente y entrega el ID seleccionado', (
    tester,
  ) async {
    service.items = [
      Reservacion(
        idReservacion: 17,
        idVehiculo: 8,
        vehiculoDescripcion: 'Toyota Corolla (A123)',
        idCliente: 4,
        clienteNombre: 'Ana Pérez',
        idEstado: 2,
        estadoCodigo: 'CONFIRMADA',
        estadoNombre: 'Confirmada',
        fechaInicio: DateTime(2027, 1, 10),
        fechaFin: DateTime(2027, 1, 12),
        observacion: '',
        fechaCreacion: DateTime(2026, 10, 6),
      ),
    ];
    int? selected;
    await show(tester, onChanged: (value) => selected = value);
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('#17 · Toyota Corolla (A123) · Ana Pérez').last);
    await tester.pumpAndSettle();
    expect(selected, 17);
    expect(find.textContaining('10/01/2027'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lista vacía impide convertir sin selección', (tester) async {
    await show(tester);
    expect(
      find.textContaining('No hay reservaciones confirmadas'),
      findsOneWidget,
    );
    final form = tester.state<FormState>(find.byType(Form));
    expect(form.validate(), isFalse);
    await tester.pump();
    expect(find.text('Selecciona una reservación confirmada'), findsOneWidget);
  });

  testWidgets('permite reintentar cuando falla la recuperación', (
    tester,
  ) async {
    service.fail = true;
    await show(tester);
    expect(
      find.text('No se pudieron recuperar las reservaciones.'),
      findsOneWidget,
    );
    service.fail = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudieron recuperar las reservaciones.'),
      findsNothing,
    );
    expect(
      find.textContaining('No hay reservaciones confirmadas'),
      findsOneWidget,
    );
  });
}
